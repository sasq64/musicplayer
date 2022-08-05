#include "MDXPlugin.h"
namespace musix {
static ChipPlugin::RegisterMe
    registerMe([](const std::string& configDir) -> std::shared_ptr<MDXPlugin> {
        return std::make_shared<MDXPlugin>();
    });
}
