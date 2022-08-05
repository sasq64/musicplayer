#include "OpenMPTPlugin.h"
namespace musix {
static ChipPlugin::RegisterMe registerMe(
    [](const std::string& configDir) -> std::shared_ptr<OpenMPTPlugin> {
        return std::make_shared<OpenMPTPlugin>();
    });
}
