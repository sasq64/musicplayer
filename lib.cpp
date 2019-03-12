
#include <string>

#include <audioplayer/audioplayer.h>
#include <coreutils/fifo.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

//#include "plugins/plugins.h"
#include "chipplayer.h"
#include "chipplugin.h"

#ifdef _WIN32
#define API __declspec(dllexport)
#else
#define API
#endif

extern "C" API int musix_create(const char* dataDir)
{
    musix::ChipPlugin::createPlugins(dataDir);
    return 0;
}

extern "C" API void* musix_find_plugin(const char* fileName)
{
    using namespace musix;

    for (const auto& plugin : ChipPlugin::getPlugins()) {
        if (plugin->canHandle(fileName)) {
            return plugin.get();
        }
    }
    return nullptr;
}

extern "C" API void* musix_plugin_create_player(void* plugin, const char* fileName)
{
    using namespace musix;
    auto* chipPlugin = static_cast<ChipPlugin*>(plugin);
    return chipPlugin->fromFile(fileName);
}

extern "C" API void musix_player_destroy(void* player)
{
    using namespace musix;
    delete static_cast<ChipPlayer*>(player);
}

extern "C" API int musix_player_get_samples(void* player, int16_t* target, int size)
{
    using namespace musix;
    auto* chipPlayer = static_cast<ChipPlayer*>(player);
    return chipPlayer->getSamples(target, size);
}

extern "C" API const char* musix_player_get_meta(void* player, const char* what)
{
    using namespace musix;
    auto* chipPlayer = static_cast<ChipPlayer*>(player);
    return strdup(chipPlayer->getMeta(what).c_str());
}

extern "C" API void musix_player_seek(void* player, int song, int seconds)
{
    using namespace musix;
    auto* chipPlayer = static_cast<ChipPlayer*>(player);
    chipPlayer->seekTo(song, seconds);
}
