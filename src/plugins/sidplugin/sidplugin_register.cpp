#include "SidPlugin.h"
#include <STIL.hpp>
namespace musix {
static ChipPlugin::RegisterMe
    registerMe([](const std::string& configDir) -> std::shared_ptr<ChipPlugin> {
        return std::make_shared<SidPlugin>(configDir);
    });
}
