#include <string>

#include <audioplayer/audioplayer.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include "plugins/plugins.h"

int main(int argc, const char **argv) {
    using musix::ChipPlayer;
    using musix::ChipPlugin;

    if(argc < 2)
        return 0;

    logging::setLevel(logging::LogLevel::WARNING);

    std::string name = argv[1];
    std::string pluginName;

    ChipPlugin::createPlugins("data");

    std::shared_ptr<ChipPlayer> player;
    for(auto &plugin : ChipPlugin::getPlugins()) {
        if(plugin->canHandle(name)) {
            auto ptr = plugin->fromFile(name);
            if(ptr != nullptr) {
                player = std::shared_ptr<ChipPlayer>(ptr);
                pluginName = plugin->name();
                break;
            }
        }
    }
    if(!player) {
        printf("No plugin could handle file\n");
        return 0;
    }
    int len = player->getMetaInt("length");
    auto title = player->getMeta("title");
    if(title.empty())
        title = utils::path_basename(name);

    auto format = player->getMeta("format");
    printf("Playing: %s [%s/%s] (%02d:%02d)\n", title.c_str(),
           pluginName.c_str(), format.c_str(), len / 60, len % 60);

    utils::Fifo<int16_t> fifo{32768};

    AudioPlayer::play([&](int16_t *ptr, int size) { fifo.get(ptr, size); });

    std::vector<int16_t> temp(1024 * 4);
    while(true) {
        int rc = player->getSamples(&temp[0], temp.size());
        if(rc > 0)
            fifo.put(&temp[0], rc);
        utils::sleepms(1);
    }
    return 0;
}
