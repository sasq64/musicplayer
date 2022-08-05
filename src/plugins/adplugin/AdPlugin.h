#pragma once

#include "../../chipplugin.h"

namespace musix {

class AdPlugin : public ChipPlugin
{
public:
    explicit AdPlugin(const std::string& configDir) : configDir(configDir) {}
    std::string name() const override { return "AdPlug"; }
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;

private:
    std::string configDir;
};

} // namespace musix

