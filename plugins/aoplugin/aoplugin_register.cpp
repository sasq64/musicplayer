#include "AOPlugin.h"
namespace musix {
static ChipPlugin::RegisterMe
    registerMe([](const std::string &configDir) -> std::shared_ptr<AOPlugin> {
        return std::make_shared<AOPlugin>();
    });
}
