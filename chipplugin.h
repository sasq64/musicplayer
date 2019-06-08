#pragma once

#include <algorithm>
#include <functional>
#include <memory>
#include <string>
#include <vector>

namespace utils {
template <typename T> class Fifo;
} // namespace utils

#include "chipplayer.h"

namespace musix {

class ChipPlugin
{
public:
    virtual ~ChipPlugin() = default;
    ;

    // Must be implemented
    virtual std::string name() const = 0;
    virtual bool canHandle(const std::string& name) = 0;
    virtual ChipPlayer* fromFile(const std::string& fileName) = 0;

    virtual ChipPlayer*
        fromStream(std::shared_ptr<utils::Fifo<uint8_t>> /*unused*/)
    {
        return nullptr;
    }
    virtual int priority() { return 0; }

    // Normally a player stops playing when music is silent, but can be
    // overriden by plugin
    virtual bool checkSilence() const { return true; }

    // Return other files required for playing the provided file. The returned
    // files should normally not contain a path if it assumed they recide in
    // the same directory.
    virtual std::vector<std::string> getSecondaryFiles(const std::string& file)
    {
        return std::vector<std::string>();
    }

    // Plugin registration stuff

    using PluginConstructor =
        std::function<std::shared_ptr<ChipPlugin>(const std::string&)>;

    static void createPlugins(const std::string& configDir)
    {
        if (pluginConstructors().empty()) {
            fprintf(stderr, "No plugins registered!\n");
        }
        auto& plugins = getPlugins();
        for (const auto& f : pluginConstructors()) {
            plugins.push_back(f(configDir));
        }

        std::sort(plugins.begin(), plugins.end(),
                  [](std::shared_ptr<ChipPlugin> a,
                     std::shared_ptr<ChipPlugin> b) -> bool {
                      return a->priority() > b->priority();
                  });
        pluginConstructors().clear();
    }

    static void addPlugin(std::shared_ptr<ChipPlugin> plugin, bool first)
    {
        if (first)
            getPlugins().insert(getPlugins().begin(), plugin);
        else
            getPlugins().push_back(plugin);
    }

    static std::shared_ptr<ChipPlugin> getPlugin(const std::string& name)
    {
        for (auto& p : getPlugins()) {
            if (p->name() == name)
                return p;
        }
        return nullptr;
    }

    static void addPluginConstructor(PluginConstructor pc)
    {
        pluginConstructors().push_back(pc);
    }

    // Static instances of this struct is used for automatic registration of
    // linked plugins
    struct RegisterMe
    {
        RegisterMe(PluginConstructor f)
        {
            ChipPlugin::addPluginConstructor(f);
        };
    };

    static std::vector<std::shared_ptr<ChipPlugin>>& getPlugins()
    {
        static std::vector<std::shared_ptr<ChipPlugin>> plugins;
        return plugins;
    }

private:
    // Small trick to put a static variable in an h-file only
    static std::vector<PluginConstructor>& pluginConstructors()
    {
        static std::vector<PluginConstructor> constructors;
        return constructors;
    };
};

} // namespace musix
