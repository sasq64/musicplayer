#include "player.hpp"

#include "chipplayer.h"
#include "chipplugin.h"

#include <audioplayer/audioplayer.h>
#include <chrono>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <csignal>
#include <deque>
#include <fcntl.h>
#include <readerwriterqueue.h>

#include "resampler.h"

#include <atomic>
#include <thread>

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
    std::string pluginName;
    std::vector<Info> infoList;

    Resampler<32768> fifo{44100};
    AudioPlayer audioPlayer{44100};
    int _current_song{};

public:
    std::shared_ptr<musix::ChipPlayer> get_player() { return player; }

    Player()
    {
        using musix::ChipPlayer;
        using musix::ChipPlugin;

        logging::setLevel(logging::Level::Warning);

        auto xd = utils::get_exe_dir();
        auto home = utils::get_home_dir();
        auto searchPath = std::vector{fs::absolute(xd / ".." / "data"),
                                      fs::absolute(xd / ".." / ".." / "data"),
                                      home / ".local" / "share" / "musix",
                                      home / ".config" / "musix",
                                      fs::path("/usr/share/musix"),
                                      fs::path("/usr/local/share/musix")};
        fs::path dataPath;
        for (auto&& p : searchPath) {
            if (fs::exists(p)) {
                dataPath = p;
                break;
            }
        }
        if (dataPath.empty()) {
            throw musix::player_exception("Could not find data directory");
        }
        ChipPlugin::createPlugins(dataPath.string());

        audioPlayer.play([&](int16_t* ptr, int size) {
            auto count = fifo.read(ptr, size);
            if (count <= 0) { memset(ptr, 0, size * 2); }
        });
    }

    std::deque<fs::path> play_list;

    void play(fs::path const& name) override
    {
        play_list.push_back(name);
        if (player == nullptr) { play_next(); }
    }

    void clear() override
    {
        player = nullptr;
        play_list.clear();
    }
    using clk = std::chrono::system_clock;
    std::chrono::time_point<clk> start_time;

    uint32_t last_secs = 0;
    uint32_t length = 0;

    void play_next()
    {
        player = nullptr;
        if (play_list.empty()) { return; }

        auto songFile = play_list.front();
        play_list.pop_front();

        for (const auto& plugin : musix::ChipPlugin::getPlugins()) {
            if (plugin->canHandle(songFile.string())) {
                if (auto* ptr = plugin->fromFile(songFile)) {
                    player = std::shared_ptr<musix::ChipPlayer>(ptr);
                    pluginName = plugin->name();
                    break;
                }
            }
        }
        if (!player) {
            return;
        }

        length = 0;
        infoList.clear();
        infoList.emplace_back("init", ""s);
        infoList.emplace_back("filename", songFile.string());
        player->onMeta([this](auto&& meta_list, auto*) {
            for (auto&& name : meta_list) {
                auto&& val = player->meta(name);
                infoList.emplace_back(name, val);
                if (name == "length") { length = std::get<uint32_t>(val); }
            }
        });
        start_time = clk::now();
        _current_song = player->getMetaInt("startSong");
    }

    std::vector<Info> get_info() override
    {
        auto result = infoList;
        infoList.clear();
        return result;
    }

    void next() override
    {
        play_next();
    }

    void set_song(int song) override {
        if(player->seekTo(song)) {
            start_time = clk::now();
        }
    }

    void update() override
    {
        if (player == nullptr) {
            play_next();
            return;
        }

        uint32_t secs = (std::chrono::duration_cast<std::chrono::seconds>(
                             clk::now() - start_time))
                            .count();
        if (secs != last_secs) {
            if (infoList.empty()) { infoList.emplace_back("seconds", secs); }
            last_secs = secs;
        }

        std::array<int16_t, 1024 * 16> temp{};
        fifo.setHz(player->getHZ());
        auto rc =
            player->getSamples(temp.data(), static_cast<int>(temp.size()));
        if (rc > 0) { fifo.write(&temp[0], &temp[1], rc); }
        if (rc <= 0 || (length > 0 && secs > length)) {
            if (!play_list.empty()) {
                play_next();
            }
        }
    }
};

class ThreadedPlayer : public MusicPlayer
{
    Player player;
    std::thread playThread;
    std::atomic<bool> quit{false};

    struct Next
    {};
    struct Play
    {
        fs::path name;
    };
    struct SetSong
    {
        int song;
    };
    struct Clear {};

    using Command = std::variant<Next, SetSong, Play, Clear>;

    moodycamel::ReaderWriterQueue<Command> commands;
    moodycamel::ReaderWriterQueue<std::vector<Info>> infos;

    void handle_cmd(Next const&) { player.next(); }
    void handle_cmd(Clear const&) { player.clear(); }
    void handle_cmd(SetSong const& cmd) { player.set_song(cmd.song); }
    void handle_cmd(Play const& cmd) { player.play(cmd.name); }

    void update() override
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
                update();
                std::this_thread::sleep_for(std::chrono::milliseconds(10));
            }
        });
    }

public:
    void play(fs::path const& name) override { commands.emplace(Play{name}); }
    void next() override { commands.emplace(Next{}); }
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
    int childPid = -1;
    FILE* infile;
    FILE* cmdfile;

    std::unordered_map<std::string, Meta> currentInfo;

public:
    PipePlayer()
    {
        auto fifo_in = utils::get_home_dir() / ".musix_fifo_in";
        auto fifo_out = utils::get_home_dir() / ".musix_fifo_out";

        if (!fs::exists(fifo_in)) { mkfifo(fifo_in.c_str(), 0777); }

        if (!fs::exists(fifo_out)) { mkfifo(fifo_out.c_str(), 0777); }

        // puts("open");
        int fd = open(fifo_out.c_str(), O_RDONLY | O_NONBLOCK | O_CLOEXEC);
        infile = fdopen(fd, "r");

        int test_fd = open(fifo_in.c_str(), O_WRONLY | O_NONBLOCK | O_CLOEXEC);
        if (test_fd > 0) {
            // puts("Someone at the other end");
            cmdfile = fdopen(test_fd, "w");
            int rc = 1;
            std::array<char, 128> temp;
            while (fgets(temp.data(), temp.size(), infile) != nullptr) {}

            fputs(fmt::format("d{}\n", fs::current_path().string()).c_str(),
                  cmdfile);
            fflush(cmdfile);
            fputs("?\n", cmdfile);
            fflush(cmdfile);
            return;
        }

        fd = open(fifo_in.c_str(), O_RDONLY | O_NONBLOCK | O_CLOEXEC);
        FILE* myfile = fdopen(fd, "r");

        fd = open(fifo_out.c_str(), O_WRONLY | O_NONBLOCK | O_CLOEXEC);
        FILE* outfile = fdopen(fd, "w");

        fd = open(fifo_in.c_str(), O_WRONLY | O_NONBLOCK | O_CLOEXEC);
        cmdfile = fdopen(fd, "w");
        // puts("Done");

        pid_t pid = fork();
        if (pid < 0) { exit(EXIT_FAILURE); }
        if (pid > 0) {
            childPid = pid;
            return;
            // exit(EXIT_SUCCESS);
        }
        // Child starting
        umask(0);
        auto sid = setsid();
        if (sid < 0) { exit(EXIT_FAILURE); }

        // close(STDIN_FILENO);
        // close(STDOUT_FILENO);
        // close(STDERR_FILENO);
        // puts("player");
        ThreadedPlayer player;
        std::string l;
        bool quit = false;
        while (!quit) {
            l.resize(128);
            while (fgets(l.data(), 128, myfile) != nullptr) {
                l.resize(strlen(l.data()) - 1);
                if (l[0] == '>') {
                    player.play(l.substr(1));
                } else if (l[0] == 'n') {
                    player.next();
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
                            "i{}\t{}\n", info.first,
                            std::visit(
                                [](auto v) { return fmt::format("{}", v); },
                                info.second));
                        fputs(line.c_str(), outfile);
                    }
                    fflush(outfile);
                }
                l.resize(128);
            }
            auto allInfo = player.get_info();
            if (!allInfo.empty()) {
                // puts("info");
                for (auto&& info : allInfo) {
                    if (info.first != "init") {
                        currentInfo[info.first] = info.second;
                    }
                    auto line = fmt::format(
                        "i{}\t{}\n", info.first,
                        std::visit([](auto v) { return fmt::format("{}", v); },
                                   info.second));
                    // puts(line.c_str());
                    fputs(line.c_str(), outfile);
                }
                fflush(outfile);
                // puts("info done");
            }
            std::this_thread::sleep_for(10ms);
        }
        exit(0);
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
        // if (childPid > 0) { kill(childPid, SIGINT); }
    }

    void play(fs::path const& name) override
    {
        auto line = fmt::format(">{}\n", name.string());
        if (fputs(line.c_str(), cmdfile) < 0) { fmt::print("FAILED\n"); }
        fflush(cmdfile);
    }

    void next() override
    {
        fputs("n\n", cmdfile);
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
                auto [meta, val] = utils::splitn<2>(line.substr(1), "\t"s);
                // fmt::print("{}={}\n", meta, val);
                if (utils::startsWith(meta, "song") || meta == "length" ||
                    meta == "startSong" || meta == "seconds") {
                    result.emplace_back(meta,
                                        static_cast<uint32_t>(std::stol(val)));
                } else {
                    result.emplace_back(meta, val);
                }
            }
            line.resize(1024);
        }
        return result;
    }
    void detach() override { detached = true; }
};

std::unique_ptr<MusicPlayer> MusicPlayer::create()
{
    return std::make_unique<PipePlayer>();
}
