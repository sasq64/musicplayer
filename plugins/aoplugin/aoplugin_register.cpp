#include "AOPlugin.h"
namespace chipmachine {
static ChipPlugin::RegisterMe registerMe([](const std::string &configDir) -> std::shared_ptr<AOPlugin> { return std::make_shared<AOPlugin>(); });
}
