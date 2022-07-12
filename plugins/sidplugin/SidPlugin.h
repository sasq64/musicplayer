#pragma once

#include "../../chipplugin.h"
#include <thread>

class STIL;

namespace musix {

class SidPlugin : public ChipPlugin {
    std::unique_ptr<STIL> stil;
    std::thread initThread;
public:
    explicit SidPlugin(std::string const& configDir);
    ~SidPlugin() override;
    std::string name() const override { return "SidPlugin"; }
    bool canHandle(const std::string& name) override;
    int priority() override { return -1; }
    ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix
