
#include <string>

#include <fmt/format.h>

#include <audioplayer/audioplayer.h>
#include <coreutils/fifo.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

//#include "plugins/plugins.h"
#include "chipplayer.h"
#include "chipplugin.h"

using musix::ChipPlayer;
using musix::ChipPlugin;

#ifdef _WIN32
#    define API __declspec(dllexport)
#else
#    define API
#endif

extern "C" API int musix_create(const char* dataDir)
{
    musix::ChipPlugin::createPlugins(dataDir);
    return 0;
}

extern "C" API void* musix_find_plugin(const char* fileName)
{

    for (const auto& plugin : ChipPlugin::getPlugins()) {
        if (plugin->canHandle(fileName)) { return plugin.get(); }
    }
    return nullptr;
}

extern "C" API void* musix_plugin_create_player(void* plugin,
                                                const char* fileName)
{
    auto* chipPlugin = static_cast<ChipPlugin*>(plugin);
    return chipPlugin->fromFile(fileName);
}

extern "C" API void musix_player_destroy(void* player)
{
    delete static_cast<ChipPlayer*>(player);
}

extern "C" API int musix_player_get_samples(void* player, int16_t* target,
                                            int size)
{
    auto* chipPlayer = static_cast<ChipPlayer*>(player);
    return chipPlayer->getSamples(target, size);
}

extern "C" API const char* musix_player_get_meta(void* player, const char* what)
{
    auto* chipPlayer = static_cast<ChipPlayer*>(player);
    auto s = std::visit([](auto&& x) { return fmt::format("{}", x); },
                        chipPlayer->meta(what));
    return strdup(s.c_str());
}

extern "C" API void musix_player_seek(void* player, int song, int seconds)
{
    auto* chipPlayer = static_cast<ChipPlayer*>(player);
    chipPlayer->seekTo(song, seconds);
}
