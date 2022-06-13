
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

using namespace std::string_literals;

int main(int argc, const char** argv)
{
    using musix::ChipPlayer;
    using musix::ChipPlugin;

    if (argc < 2) { return 0; }

    logging::setLevel(logging::Level::Debug);

    std::string name = argv[1];

    std::string pluginName;

    ChipPlugin::createPlugins("data");

    std::shared_ptr<ChipPlayer> player;

    for (const auto& plugin : ChipPlugin::getPlugins()) {
        if (plugin->canHandle(name)) {
            if (auto* ptr = plugin->fromFile(name)) {
                player = std::shared_ptr<ChipPlayer>(ptr);
                pluginName = plugin->name();
                break;
            }
        }
    }
    if (!player) {
        fmt::print("No plugin could handle file\n");
        return 0;
    }
    player->onMeta([](auto&& meta_list, auto* player) {
        for(auto&& meta : meta_list) {
            auto val = player->getMeta(meta);
            fmt::print("{} = {}\n", meta, val);
        }
    });
    auto len = player->getMetaInt("length");
    auto title = player->getMeta("title");
    auto sub_title = player->getMeta("sub_title");
    if (title.empty()) { title = utils::path_basename(name); }

    auto format = player->getMeta("format");
    fmt::print("Playing: {} ({}) [{}/{}] ({:02}:{:02})\n", title, sub_title,
           pluginName, format, len / 60, len % 60);

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
