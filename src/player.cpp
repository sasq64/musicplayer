#include "player.hpp"

#include "chipplayer.h"
#include "chipplugin.h"

#include <audioplayer/audioplayer.h>
#include <chrono>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <deque>
#include <fcntl.h>
#include <filesystem>
#include <readerwriterqueue.h>

#include "resampler.h"

#include <atomic>
#include <thread>

namespace fs = std::filesystem;

using namespace std::string_literals;
using namespace std::chrono_literals;

namespace std {
std::string to_string(std::string const& s)
{
    return s;
}
} // namespace std

class Player : public MusicPlayer
{

    std::shared_ptr<musix::ChipPlayer> player;
    std::vector<Info> infoList;
    int startSong = -1;

    Resampler<32768> fifo{44100};
    AudioPlayer audioPlayer{44100};

    std::deque<fs::path> play_list;
    std::deque<fs::path> played;

    uint32_t last_secs = 0;
    uint64_t micro_seconds = 0;
    uint32_t length = 0;
    uint32_t forced_length = 0;
    uint32_t songs = 0;

public:
    std::shared_ptr<musix::ChipPlayer> get_player() { return player; }

    static inline fs::path CreatePlugins()
    {
        using musix::ChipPlayer;
        using musix::ChipPlugin;

        logging::setLevel(logging::Level::Warning);

        auto dataPath = findDataPath();

        if (dataPath.empty()) {
            throw musix::player_exception("Could not find data directory");
        }
        ChipPlugin::createPlugins(dataPath.string());
        return dataPath;
    }

    static inline std::shared_ptr<musix::ChipPlayer>
    createPlayer(fs::path const& songFile)
    {
        std::shared_ptr<musix::ChipPlayer> player;
        for (const auto& plugin : musix::ChipPlugin::getPlugins()) {
            if (plugin->canHandle(songFile.string())) {
                try {
                    if (auto* ptr = plugin->fromFile(songFile)) {
                        player = std::shared_ptr<musix::ChipPlayer>(ptr);
                        break;
                    }
                } catch (musix::player_exception& e) {
                    player = nullptr;
                }
            }
        }
        return player;
    }

    Player()
    {
        CreatePlugins();
        audioPlayer.play([&](int16_t* ptr, int size) {
            auto count = fifo.read(ptr, size);
            if (count <= 0) { memset(ptr, 0, size * 2); }
        });
    }

    void add(fs::path const& name) override
    {
        play_list.push_back(name);
        if (player == nullptr) { play_next(); }
    }

    void clear() override
    {
        player = nullptr;
        play_list.clear();
    }

    void play_next()
    {
        if (play_list.empty()) { return; }
        player = nullptr;

        while (player == nullptr && !play_list.empty()) {
            auto songFile = play_list.front();
            play_list.pop_front();
            played.push_back(songFile);
            play(songFile);
        }
    }

    void play_prev()
    {
        if (played.size() < 2) { return; }
        player = nullptr;

        while (player == nullptr && played.size() >= 2) {
            auto songFile = played.back();
            played.pop_back();
            play_list.push_front(songFile);
            play(played.back());
        }
    }

    void play(fs::path const& sf)
    {
        auto songFile = sf;
        songs = length = forced_length = 0;

        auto&& s = songFile.string();
        auto pos = s.find_last_of(';');
        if (pos != std::string::npos) {
            songFile = s.substr(0, pos);
            length = forced_length = std::stol(s.substr(pos+1));
        }

        if (fs::is_directory(songFile)) {
            for (const auto& entry : fs::directory_iterator(songFile)) {
                auto&& p = entry.path().string();
                if (p[0] == '.' && (p[1] == 0 || (p[1] == '.' && p[2] == 0))) {
                    continue;
                }
                play_list.push_front(entry.path());
            }
            played.pop_back();
            play_next();
            return;
        }

        player = createPlayer(songFile);
        if (!player) { return; }

        if (startSong >= 0) {
            player->seekTo(startSong, -1);
            startSong = -1;
        }
        std::error_code ec;
        auto fsize = fs::file_size(songFile, ec);

        infoList.clear();
        infoList.emplace_back("init", ""s);
        infoList.emplace_back("list_length",
                              static_cast<uint32_t>(play_list.size()));
        infoList.emplace_back("file_size", static_cast<uint32_t>(fsize));

        infoList.emplace_back("filename", fs::absolute(songFile).string());
        player->onMeta([this](auto&& meta_list, auto*) {
            for (auto&& name : meta_list) {
                auto&& val = player->meta(name);
                infoList.emplace_back(name, val);
                if (name == "length" && forced_length == 0) {
                    length = std::get<uint32_t>(val);
                } else
                if (name == "songs") { songs = std::get<uint32_t>(val); }
            }
        });

        if (length > 0) {
            infoList.emplace_back("length", length);
        }

        micro_seconds = 0;
        fifo.silence = 0;
    }

    std::vector<Info> get_info() override
    {
        auto result = infoList;
        infoList.clear();
        return result;
    }

    void next() override { play_next(); }
    void prev() override { play_prev(); }

    void set_song(int song) override
    {
        if (player == nullptr) { startSong = song; }
        if (song < 0 || song >= songs) { return; }
        if (player->seekTo(song)) {
            micro_seconds = 0;
            fifo.silence = 0;
        }
    }

    void update() override
    {
        if (player == nullptr) {
            // play_next();
            return;
        }

        uint32_t secs = micro_seconds / 1000000;

        if (secs != last_secs) {
            if (infoList.empty()) { infoList.emplace_back("seconds", secs); }
            last_secs = secs;
        }

        std::array<int16_t, 1024 * 16> temp{};
        auto hz = player->getHZ();
        fifo.setHz(hz);
        auto rc =
            player->getSamples(temp.data(), static_cast<int>(temp.size()));
        if (rc > 0) {
            fifo.write(temp.data(), temp.data() + 1, rc);
            micro_seconds += (static_cast<uint64_t>(rc) * (1000000 / 2) / hz);
        }
        if (rc <= 0 || (length > 0 && secs > length) ||
            (micro_seconds > 5000000 && fifo.silence > 10)) {
            play_next();
        }
    }
    void seek(int offset_ms) {


    }
};

class OutPlayer : public MusicPlayer
{

    std::shared_ptr<musix::ChipPlayer> player;
    std::vector<Info> infoList;
    Resampler<32768> fifo{44100};
    int startSong = -1;

public:
    OutPlayer() { Player::CreatePlugins(); }

    void add(fs::path const& name) override
    {
        uint32_t length = 0;
        auto songFile = name;
        auto&& s = name.string();
        auto pos = s.find_last_of(';');
        if (pos != std::string::npos) {
            songFile = s.substr(0, pos);
            length =  std::stol(s.substr(pos+1));
        }

        auto out_fd = dup(STDOUT_FILENO); // NOLINT
        close(STDOUT_FILENO);
        player = Player::createPlayer(songFile);
        if (player == nullptr) { return; }
        if (startSong >= 0) { player->seekTo(startSong, -1); }

        uint32_t songs = 0;
        player->onMeta([&](auto&& meta_list, auto*) {
            for (auto&& name : meta_list) {
                auto&& val = player->meta(name);
                infoList.emplace_back(name, val);
                if (name == "length" && length == 0) { length = std::get<uint32_t>(val); }
                if (name == "songs") { songs = std::get<uint32_t>(val); }
            }
        });

        if (length <= 0) { length = 60 * 4; }

        uint64_t micro_seconds = 0;

        std::array<int16_t, 1024 * 16> temp{};
        bool done = false;
        while (!done) {
            auto hz = player->getHZ();
            fifo.setHz(hz);
            auto rc =
                player->getSamples(temp.data(), static_cast<int>(temp.size()));
            if (rc > 0) {
                fifo.write(temp.data(), temp.data() + 1, rc);
                micro_seconds +=
                    (static_cast<uint64_t>(rc) * (1000000 / 2) / hz);
            } else {
                done = true;
            }
            if (micro_seconds / 1000000 > length) { done = true; }

            auto count = fifo.read(temp.data(), temp.size());
            if (write(out_fd, temp.data(), count * 2) <= 0) { done = true; }
        }
    }
    void next() override {}
    void prev() override {}
    void clear() override {}
    void set_song(int song) override { startSong = song; }
};

class ThreadedPlayer : public MusicPlayer
{
    Player player;
    std::thread playThread;
    std::atomic<bool> quit{false};
    // clang-format off
    struct Next {};
    struct Prev {};
    struct Play { fs::path name; };
    struct SetSong { int song; };
    struct Clear {};
    struct Seek { int offset; };
    // clang-format on

    using Command = std::variant<Next, Prev, SetSong, Play, Clear, Seek>;

    moodycamel::ReaderWriterQueue<Command> commands;
    moodycamel::ReaderWriterQueue<std::vector<Info>> infos;

    void handle_cmd(Next const&) { player.next(); }
    void handle_cmd(Prev const&) { player.prev(); }
    void handle_cmd(Clear const&) { player.clear(); }
    void handle_cmd(SetSong const& cmd) { player.set_song(cmd.song); }
    void handle_cmd(Play const& cmd) { player.add(cmd.name); }
    void handle_cmd(Seek const& cmd) { player.seek(cmd.offset); }

    void read_commands()
    {
        Command cmd;
        while (commands.try_dequeue(cmd)) {
            std::visit([&](auto&& cmd) { handle_cmd(cmd); }, cmd);
        }
        auto&& info = player.get_info();
        if (!info.empty()) { infos.emplace(info); }
    }

    void run()
    {
        playThread = std::thread([this]() {
            while (!quit) {
                player.update();
                read_commands();
                std::this_thread::sleep_for(10ms);
            }
        });
    }

public:
    void add(fs::path const& name) override { commands.emplace(Play{name}); }
    void next() override { commands.emplace(Next{}); }
    void prev() override { commands.emplace(Prev{}); }
    void clear() override { commands.emplace(Clear{}); }
    void set_song(int song) override { commands.emplace(SetSong{song}); }

    std::vector<Info> get_info() override
    {
        std::vector<Info> info;
        if (infos.try_dequeue(info)) { return info; }
        return {};
    }

    ThreadedPlayer() { run(); }
    ~ThreadedPlayer() override
    {
        quit = true;
        if (playThread.joinable()) { playThread.join(); }
    }
};

class PipePlayer : public MusicPlayer
{
    FILE* infile;
    FILE* cmdfile;
    FILE* outfile;
    FILE* myfile;

    std::unordered_map<std::string, Meta> currentInfo;

public:
    PipePlayer()
    {
        auto exe_id = utils::get_exe_id();

        auto fifo_in = utils::get_home_dir() / ".musix_fifo_in";
        auto fifo_out = utils::get_home_dir() / ".musix_fifo_out";

        if (!fs::exists(fifo_in)) { mkfifo(fifo_in.c_str(), 0777); }

        if (!fs::exists(fifo_out)) { mkfifo(fifo_out.c_str(), 0777); }

        int fd = open(fifo_out.c_str(), O_RDONLY | O_NONBLOCK | O_CLOEXEC);
        infile = fdopen(fd, "r");

        int test_fd = open(fifo_in.c_str(), O_WRONLY | O_NONBLOCK | O_CLOEXEC);
        if (test_fd > 0) {
            auto contents =
                utils::read_as_string(utils::get_home_dir() / ".musix.id");
            auto id = contents.empty() ? 0 : std::stol(contents);
            if (id == exe_id) {
                close(test_fd);
                test_fd = open(fifo_in.c_str(), O_WRONLY | O_CLOEXEC);

                cmdfile = fdopen(test_fd, "w");
                std::array<char, 128> temp{};
                // Throw away anything still in the fifo since last session
                while (fgets(temp.data(), temp.size(), infile) != nullptr) {}
                fputs(fmt::format("d{}\n", fs::current_path().string()).c_str(),
                      cmdfile);
                fputs("?\n", cmdfile);
                fflush(cmdfile);
                return;
            }
            auto _ = write(test_fd, "q\n", 2);
            close(test_fd);
            fmt::print("Player was updated!\nYou may have to manually kill "
                       "the running player process!\n");
            exit(0);
        }

        utils::write_as_string(utils::get_home_dir() / ".musix.id",
                               std::to_string(exe_id));

        fd = open(fifo_in.c_str(), O_RDONLY | O_NONBLOCK | O_CLOEXEC);
        myfile = fdopen(fd, "r");

        fd = open(fifo_out.c_str(), O_WRONLY | O_CLOEXEC);
        outfile = fdopen(fd, "w");

        fd = open(fifo_in.c_str(), O_WRONLY | O_CLOEXEC);
        cmdfile = fdopen(fd, "w");

        pid_t pid = fork();
        if (pid < 0) { throw musix::player_exception("Could not fork"); }
        if (pid > 0) {
            // In parent, return
            return;
        }

        runChild();
        exit(0); // NOLINT
    }

    void runChild()
    {
        // Child starting
        umask(0);
        auto sid = setsid();
        if (sid < 0) { throw musix::player_exception("Could not setsid("); }

        if (freopen((utils::get_home_dir() / ".musix.stdout").c_str(), "w",
                    stdout) == nullptr) {
            // Oh well
        }
        close(STDIN_FILENO);
        log("Creating player");
        ThreadedPlayer player;
        std::string l;
        bool quit = false;
        while (!quit) {
            l.resize(1024);
            while (fgets(l.data(), 1024, myfile) != nullptr) {
                l.resize(strlen(l.data()) - 1);
                log("Got command '{}'", l);
                if (l[0] == '>') {
                    player.add(l.substr(1));
                } else if (l[0] == 'n') {
                    player.next();
                } else if (l[0] == 'p') {
                    player.prev();
                } else if (l[0] == 'c') {
                    player.clear();
                } else if (l[0] == 's') {
                    auto song = std::stoi(l.substr(1));
                    player.set_song(song);
                } else if (l[0] == 'q') {
                    quit = true;
                } else if (l[0] == 'd') {
                    fs::current_path(l.substr(1));
                } else if (l[0] == '?') {
                    for (auto&& info : currentInfo) {
                        auto line = fmt::format(
                            "i{}\t{}\t{}\n", info.second.index(), info.first,
                            std::visit(
                                [](auto v) { return fmt::format("{}", v); },
                                info.second));
                        fputs(line.c_str(), outfile);
                    }
                    fflush(outfile);
                }
                l.resize(1024);
            }
            if (ferror(myfile) > 0) {
                if (errno != EAGAIN && errno != EWOULDBLOCK) {
                    log("ERROR: Failed to read pipe: {}", strerror(errno));
                    exit(1);
                }
                clearerr(myfile);
            }
            auto allInfo = player.get_info();
            if (!allInfo.empty()) {
                log("Got {} infos from player", allInfo.size());
                for (auto&& info : allInfo) {
                    if (info.first != "init") {
                        currentInfo[info.first] = info.second;
                    } else {
                        log("Clearing");
                        currentInfo.clear();
                    }

                    auto line = fmt::format(
                        "i{}\t{}\t{}", info.second.index(), info.first,
                        std::visit([](auto v) { return fmt::format("{}", v); },
                                   info.second));
                    for (auto& c : line) {
                        if (c == 10 || c == 13) { c = ' '; }
                    }
                    log("Info: {}", line.substr(1));
                    fputs((line + "\n").c_str(), outfile);
                }
                fflush(outfile);
            }
            std::this_thread::sleep_for(10ms);
        }
        puts("Player process exiting");
    }

    bool detached = false;
    ~PipePlayer() override
    {
        if (!detached) {
            fputs("q\n", cmdfile);
            fflush(cmdfile);
        }
        fclose(cmdfile);
        fclose(infile);
    }

    void add(fs::path const& name) override
    {
        auto line = fmt::format(">{}\n", name.string());
        auto rc = fwrite(line.c_str(), 1, line.length(), cmdfile);
        if (rc < line.length()) {
            fmt::print("FAILED\n");
            fflush(stdout);
            exit(1);
        }
        fflush(cmdfile);
    }

    void next() override
    {
        fputs("n\n", cmdfile);
        fflush(cmdfile);
    }

    void prev() override
    {
        fputs("p\n", cmdfile);
        fflush(cmdfile);
    }

    void clear() override
    {
        fputs("c\n", cmdfile);
        fflush(cmdfile);
    }

    void set_song(int song) override
    {
        fputs(fmt::format("s{}\n", song).c_str(), cmdfile);
        fflush(cmdfile);
    }

    std::vector<Info> get_info() override
    {
        std::string line;
        line.resize(1024);
        std::vector<Info> result;

        while (fgets(line.data(), 1024, infile) != nullptr) {
            line.resize(strlen(line.data()));
            // puts(line.c_str());
            if (line[0] == 'i') {
                line = line.substr(0, line.length() - 1);
                auto [idxs, meta, val] =
                    utils::splitn<3>(line.substr(1), "\t"s);
                try {
                    auto index = std::stol(idxs);
                    Meta m;
                    if (index == 0) {
                        m = val;
                    } else {
                        m = static_cast<uint32_t>(std::stol(val));
                    }
                    result.emplace_back(meta, m);
                } catch (std::invalid_argument&) {
                    fprintf(stderr, "Cant convert '%s' to int\n", idxs.c_str());
                }
            }
            line.resize(1024);
        }
        return result;
    }
    void detach() override { detached = true; }
};

std::unique_ptr<MusicPlayer> MusicPlayer::create(MusicPlayer::Type pt)
{
    switch (pt) {
    case Type::Piped:
        return std::make_unique<PipePlayer>();
    case Type::Writer:
        return std::make_unique<OutPlayer>();
    case Type::Basic:
        return std::make_unique<ThreadedPlayer>();
    }
    return nullptr;
}

