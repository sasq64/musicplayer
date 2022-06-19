
#include "chipplayer.h"
#include "chipplugin.h"

#include <audioplayer/audioplayer.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include "resampler.h"

#include <atomic>
#include <csignal>
#include <fmt/format.h>
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
    for(int i=1; i<argc; i++) {
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
    auto search_path = std::vector{fs::absolute(xd / ".." / "data"),
                                   fs::absolute(xd / ".." / ".." / "data"),
                                   fs::path("/usr/share/musix"),
                                   fs::path("/usr/local/share/musix")};
    fs::path dataPath;
    for(auto&& p : search_path) {
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
            if (auto* ptr = plugin->fromFile(name)) {
                try {
                    player = std::shared_ptr<ChipPlayer>(ptr);
                    pluginName = plugin->name();
                } catch (musix::player_exception& e) {
                    player = nullptr;
                }
                break;
            }
        }
    }
    if (!player) {
        fmt::print(stderr, "No plugin could handle file\n");
        return 1;
    }
    if (startSong >= 0) {
        player->seekTo(startSong);
    }
    player->onMeta([pipe](auto&& meta_list, auto* player) {
        if (pipe) { return; }
        for(auto const& meta : meta_list) {
            auto val = player->getMeta(meta);
            fmt::print("{} = {}\n", meta, val);
        }
    });
    auto len = player->getMetaInt("length");
    auto title = player->getMeta("title");
    auto sub_title = player->getMeta("sub_title");
    if (title.empty()) { title = utils::path_basename(name); }

    auto format = player->getMeta("format");
    if (!pipe) {
        fmt::print("Playing: {} ({}) [{}/{}] ({:02}:{:02})\n", title, sub_title,
               pluginName, format, len / 60, len % 60);
    }

    if (pipe) {
        std::array<int16_t, 1024 * 16> temp{};
        std::cout.setf(std::ios_base::binary);
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

#ifndef __APPLE__ // _Still_ no quick_exit() in OSX ...
    std::signal(SIGINT, [](int) { std::quick_exit(0); });
#else
    std::signal(SIGINT, [](int) { std::exit(0); });
#endif

    std::array<int16_t, 1024 * 16> temp{};
    while (true) {
        fifo.setHz(player->getHZ());
        auto rc =
            player->getSamples(temp.data(), static_cast<int>(temp.size()));
        if (rc < 0) { break; }
        fifo.write(&temp[0], &temp[1], rc);
    }
    return 0;
}
