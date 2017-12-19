#pragma once

#include "../../chipplugin.h"

namespace musix {

class AdPlugin : public ChipPlugin {
public:
    AdPlugin(const std::string &configDir) : configDir(configDir) {}
    virtual std::string name() const override { return "AdPlug"; }
    virtual bool canHandle(const std::string &name) override;
    virtual ChipPlayer *fromFile(const std::string &fileName) override;

private:
    std::string configDir;
};

} // namespace musix

