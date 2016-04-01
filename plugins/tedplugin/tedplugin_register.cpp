#include "TEDPlugin.h"
namespace chipmachine {
static ChipPlugin::RegisterMe registerMe([](const std::string &configDir) -> std::shared_ptr<TEDPlugin> { return std::make_shared<TEDPlugin>(); });
}
