#include "S98Plugin.h"
namespace musix {
static ChipPlugin::RegisterMe
    registerMe([](const std::string& configDir) -> std::shared_ptr<S98Plugin> {
        return std::make_shared<S98Plugin>();
    });
}
