#ifndef RSN_PLAYER_H
#define RSN_PLAYER_H

#include "../../chipplugin.h"

namespace musix {

class RSNPlugin : public ChipPlugin {
public:
    RSNPlugin() {}
    // RSNPlugin(std::vector<std::shared_ptr<ChipPlugin>> &plugins) :
    // plugins(plugins) {}
    virtual std::string name() const { return "RSNPlugin"; }
    virtual ChipPlayer* fromFile(const std::string& fileName);

    virtual bool canHandle(const std::string& name);

private:
    std::vector<std::shared_ptr<ChipPlugin>> plugins;
};

} // namespace musix

#endif // RSN_PLAYER_H
