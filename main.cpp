#include <coreutils/utils.h>
#include "plugins/plugins.h"
#include <string>
#include <audioplayer/audioplayer.h>

using namespace chipmachine;

int main(int argc, const char **argv) {
    std::vector<int16_t> sound;
    std::string name = argv[1];
    ChipPlugin::createPlugins(".");
    std::shared_ptr<ChipPlayer> player;
    for(auto &plugin : ChipPlugin::getPlugins()) {
        if(plugin->canHandle(name)) {
            sound.resize(1024);
            auto ptr = plugin->fromFile(name);
            if(ptr != nullptr) {
                player = std::shared_ptr<ChipPlayer>(ptr);
                break;
            }
        }
    }
    if(!player)
        return 0;
    int len = player->getMetaInt("length");
    auto title = player->getMeta("title");
    LOGI("TITLE: %s LENGTH %d", title, len);
    AudioPlayer::play([=](int16_t *ptr, int size) {
		player->getSamples(ptr, size);
    });
	while(true)
		utils::sleepms(500);
    return 0;
}
