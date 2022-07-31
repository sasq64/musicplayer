#pragma once

#include "../../chipplugin.h"

namespace musix {

class HEPlugin : public ChipPlugin
{
public:
    explicit HEPlugin(const std::string& biosFileName)
        : biosFileName(biosFileName)
    {}
    std::string name() const override { return "HEPlugin"; }
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;

private:
    std::string biosFileName;
    bool biosLoaded = false;
};

} // namespace musix

