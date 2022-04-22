#pragma once

#include "../../chipplugin.h"

namespace musix {

class SidPlugin : public ChipPlugin {
public:
    explicit SidPlugin(std::string const& configDir);
    std::string name() const override { return "SidPlugin"; }
    bool canHandle(const std::string& name) override;
    int priority() override { return -1; }
    ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix
