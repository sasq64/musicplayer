#include "TEDPlugin.h"
namespace musix {
static ChipPlugin::RegisterMe
    registerMe([](const std::string& configDir) -> std::shared_ptr<TEDPlugin> {
        return std::make_shared<TEDPlugin>();
    });
}
