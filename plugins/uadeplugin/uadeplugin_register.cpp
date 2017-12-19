#include "UADEPlugin.h"
namespace musix {
static ChipPlugin::RegisterMe
    registerMe([](const std::string& configDir) -> std::shared_ptr<ChipPlugin> {
        return std::make_shared<UADEPlugin>(configDir);
    });
}
