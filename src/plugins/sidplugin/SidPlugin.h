#pragma once

#include "../../chipplugin.h"
#include <vector>
#include <thread>

class STIL;

namespace musix {

class SidPlugin : public ChipPlugin {
public:
    std::unique_ptr<STIL> stil;
    std::thread initThread;
    std::vector<uint8_t> kernal;
    std::vector<uint8_t> chargen;
    std::vector<uint8_t> basic;
    explicit SidPlugin(std::string const& configDir);
    ~SidPlugin() override;
    std::string name() const override { return "SidPlugin"; }
    bool canHandle(const std::string& name) override;
    int priority() override { return -1; }
    ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix
