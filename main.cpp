
#include "chipplayer.h"
#include "chipplugin.h"

#include <ansi/console.h>
#include <ansi/unix_terminal.h>

#include "ui/panel.hpp"

#include <audioplayer/audioplayer.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include "resampler.h"

#include <atomic>
#include <csignal>
#include <fmt/format.h>
#include <memory>
#include <string>
#include <string_view>

using namespace std::string_literals;

int main(int argc, const char** argv)
{
    using musix::ChipPlayer;
    using musix::ChipPlugin;

    if (argc < 2) { return 0; }

    logging::setLevel(logging::Level::Debug);

    std::string name;
    int startSong = -1;
    bool pipe = false;
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            auto opt = std::string_view(&argv[i][1]);
            if (opt == "song" || opt == "s") {
                startSong = std::stoi(argv[++i]);
            } else if (opt == "p") {
                pipe = true;
            }

        } else {
            name = argv[i];
        }
    }
    std::string pluginName;

    auto xd = utils::get_exe_dir();
    auto searchPath = std::vector{fs::absolute(xd / ".." / "data"),
                                  fs::absolute(xd / ".." / ".." / "data"),
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
        fmt::print(stderr, "Could not find data directory\n");
        return 1;
    }
    ChipPlugin::createPlugins(dataPath.string());

    std::shared_ptr<ChipPlayer> player;

    for (const auto& plugin : ChipPlugin::getPlugins()) {
        if (plugin->canHandle(name)) {
            try {
                if (auto* ptr = plugin->fromFile(name)) {
                    player = std::shared_ptr<ChipPlayer>(ptr);
                    pluginName = plugin->name();
                }
            } catch (musix::player_exception& e) {
                player = nullptr;
            }
            break;
        }
    }
    if (!player) {
        fmt::print(stderr, "No plugin could handle file\n");
        return 1;
    }

    std::unique_ptr<bbs::Terminal> term =
        std::make_unique<bbs::LocalTerminal>();
    term->open();
    auto con = std::make_shared<bbs::Console>(std::move(term));

    con->fill(0xff0000ff, 0x000000ff);
    Panel panel{con, 0, 0, 40, 10};
    panel.box(0,0,30,2, 0xff00ffff);
    panel.draw_text("Hello", 1, 1);
    panel.flush();
    panel.refresh();
    con->flush();

    if (startSong >= 0) { player->seekTo(startSong); }
    player->onMeta([pipe](auto&& meta_list, auto* player) {
        if (pipe) { return; }
        for (auto const& meta : meta_list) {
            auto val = player->getMeta(meta);
            //fmt::print("{} = {}\n", meta, val);
        }
    });
    auto len = player->getMetaInt("length");
    auto title = player->getMeta("title");
    auto sub_title = player->getMeta("sub_title");
    if (title.empty()) { title = utils::path_basename(name); }

    auto format = player->getMeta("format");
    if (!pipe) {
        //fmt::print("Playing: {} ({}) [{}/{}] ({:02}:{:02})\n", title, sub_title,
        //           pluginName, format, len / 60, len % 60);
    }

    if (pipe) {
        std::array<int16_t, 1024 * 16> temp{};
        // std::cout.setf(std::ios_base::binary);
        while (true) {
            auto rc =
                player->getSamples(temp.data(), static_cast<int>(temp.size()));
            if (rc < 0) { break; }
            std::cout.write(reinterpret_cast<const char*>(temp.data()), rc * 2);
        }
        return 0;
    }
    Resampler<32768> fifo{44100};
    AudioPlayer audioPlayer{44100};
    audioPlayer.play([&](int16_t* ptr, int size) {
        auto count = fifo.read(ptr, size);
        if (count <= 0) { memset(ptr, 0, size * 2); }
    });

    static std::atomic<bool> quit{false};

    std::signal(SIGINT, [](int) { quit = true; });

    std::array<int16_t, 1024 * 16> temp{};
    while (!quit) {

        auto key = con->read_key();
        if (key == KEY_RIGHT) { player->seekTo(++startSong, -1); }
        fifo.setHz(player->getHZ());
        auto rc =
            player->getSamples(temp.data(), static_cast<int>(temp.size()));
        if (rc < 0) { break; }
        fifo.write(&temp[0], &temp[1], rc);
    }
    return 0;
}
