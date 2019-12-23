#pragma once

#include "../../chipplugin.h"

namespace musix {

class UADEPlugin : public ChipPlugin {
public:
    explicit UADEPlugin(const std::string& dataDir) : dataDir(dataDir) {}

    std::string name() const override { return "UADE"; }
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;
	std::vector<std::string> getSecondaryFiles(const std::string &file) override;
    int priority() override { return -10; }

private:
    std::string dataDir;
};

} // namespace musix

