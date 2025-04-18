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

extern void register_plugins();

namespace musix {

class ChipPlugin
{
public:
    virtual ~ChipPlugin() = default;

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
    virtual std::vector<std::string>
    getSecondaryFiles(const std::string& /*file*/)
    {
        return {};
    }

    // Plugin registration stuff

    using PluginConstructor =
        std::function<std::shared_ptr<ChipPlugin>(const std::string&)>;

    static inline bool was_registered = false;
    static inline void createPlugins(const std::string& configDir)
    {
        if (was_registered) { return; }
        was_registered = true;
        register_plugins();
        auto& plugins = getPlugins();
        for (const auto& f : constructors) {
            plugins.push_back(f(configDir));
        }

        if (plugins.empty()) {
            fprintf(stderr, "No plugins registered!\n");
        }

        std::sort(plugins.begin(), plugins.end(),
                  [](auto const& a, auto const& b) {
                      return a->priority() > b->priority();
                  });
        constructors.clear();
    }

    static inline void addPlugin(const std::shared_ptr<ChipPlugin>& plugin, bool first)
    {
        if (first) {
            getPlugins().insert(getPlugins().begin(), plugin);
        } else {
            getPlugins().push_back(plugin);
        }
    }

    template <typename PLUGIN>
    static inline void addPlugin() {
        addPlugin(std::make_shared<PLUGIN>());
    }

    static inline std::shared_ptr<ChipPlugin> getPlugin(const std::string& name)
    {
        for (auto& p : getPlugins()) {
            if (p->name() == name) { return p; }
        }
        return nullptr;
    }

    static inline void addPluginConstructor(PluginConstructor const& pc)
    {
        constructors.push_back(pc);
    }

    // Static instances of this struct is used for automatic registration of
    // linked plugins
    struct RegisterMe
    {
        explicit RegisterMe(PluginConstructor const& f)
        {
            fprintf(stderr, "DEPRECATED!\n");
            //ChipPlugin::addPluginConstructor(f);
        };
    };

    static inline std::vector<std::shared_ptr<ChipPlugin>>& getPlugins()
    {
        static std::vector<std::shared_ptr<ChipPlugin>> plugins;
        return plugins;
    }

private:
    static inline std::vector<PluginConstructor> constructors;
};

} // namespace musix
