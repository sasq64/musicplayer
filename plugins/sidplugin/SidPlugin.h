#pragma once

#include "../../chipplugin.h"

namespace musix {

class SidPlugin : public ChipPlugin {
public:
    SidPlugin(std::string const& condifDir);
    virtual std::string name() const override { return "SidPlugin"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix
