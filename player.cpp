#include "player.hpp"

#include "chipplayer.h"
#include "chipplugin.h"

#include <audioplayer/audioplayer.h>
#include <chrono>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <readerwriterqueue.h>

#include "resampler.h"

#include <atomic>
#include <thread>

class Player : public MusicPlayer
{
    struct Next
    {};
    struct Prev
    {};
    struct Play
    {
        fs::path name;
    };

    using Command = std::variant<Next, Prev, Play>;

    moodycamel::ReaderWriterQueue<Command> commands;
    moodycamel::ReaderWriterQueue<Info> infos;

    std::shared_ptr<musix::ChipPlayer> player;
    std::string pluginName;

    Resampler<32768> fifo{44100};
    AudioPlayer audioPlayer{44100};
    int _current_song{};
    int _song_count{};

    int _length{};

public:
    std::shared_ptr<musix::ChipPlayer> get_player() { return player; }

    Player()
    {
        using musix::ChipPlayer;
        using musix::ChipPlugin;

        logging::setLevel(logging::Level::Warning);

        ChipPlugin::createPlugins("data");

        audioPlayer.play([&](int16_t* ptr, int size) {
            auto count = fifo.read(ptr, size);
            if (count <= 0) { memset(ptr, 0, size * 2); }
        });
    }

    std::string title;

    void play_(fs::path const& name)
    {
        player = nullptr;
        for (const auto& plugin : musix::ChipPlugin::getPlugins()) {
            if (plugin->canHandle(name)) {
                if (auto* ptr = plugin->fromFile(name)) {
                    player = std::shared_ptr<musix::ChipPlayer>(ptr);
                    pluginName = plugin->name();
                    break;
                }
            }
        }
        if (!player) { printf("No plugin could handle file\n"); }

        player->onMeta([this](auto&& meta_list, auto* player) {
            Info info;
            info.title = title;
            for (auto&& meta : meta_list) {
                auto val = player->getMeta(meta);
                fmt::print("{}={}\n", meta, val);
                if (meta == "title" || meta == "game") {
                    title = val;
                    info.title = val;
                }
                if (meta == "sub_title") {
                    info.title = fmt::format("{} ({})", title, val);
                }
            }
            infos.emplace(info);
        });

        _current_song = player->getMetaInt("startSong");
    }
    void play(fs::path const& name) override { commands.emplace(Play{name}); }

    void next() override { commands.emplace(Next{}); }

    void next_()
    {
        _current_song++;
        player->seekTo(_current_song);
    }
    void prev() override
    {
        _current_song--;
        player->seekTo(_current_song);
    }

    std::optional<Info> get_info() override
    {
        Info info;
        if (infos.try_dequeue(info)) { return info; }
        return std::nullopt;
    }

    void handle_cmd(Next const&) { next_(); }
    void handle_cmd(Prev const&) {}
    void handle_cmd(Play const& cmd) { play_(cmd.name); }

    void update()
    {
        Command cmd;
        if (commands.try_dequeue(cmd)) {
            std::visit([&](auto&& cmd) { handle_cmd(cmd); }, cmd);
        }
        if (player == nullptr) {

            std::this_thread::sleep_for(std::chrono::milliseconds(10));
            return;
        }
        // if (fifo.filled() > 8192) { return; }
        std::array<int16_t, 1024 * 16> temp{};
        fifo.setHz(player->getHZ());
        auto rc =
            player->getSamples(temp.data(), static_cast<int>(temp.size()));
        if (rc > 0) { fifo.write(&temp[0], &temp[1], rc); }
    }

    std::thread playThread;
    std::atomic<bool> quit{false};

    void run() override
    {
        playThread = std::thread([this]() {
            while (!quit) {
                update();
            }
        });
    }
};

std::unique_ptr<MusicPlayer> MusicPlayer::create()
{
    return std::make_unique<Player>();
}
