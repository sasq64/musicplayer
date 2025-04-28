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
    ~SidPlugin() override;
    std::string name() const override { return "SidPlugin"; }
    bool canHandle(const std::string& name) override;
    int priority() override { return -1; }
    ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix
