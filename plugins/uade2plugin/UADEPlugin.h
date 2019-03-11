#pragma once

#include "../../chipplugin.h"

namespace musix {

class UADEPlugin : public ChipPlugin {
public:
    UADEPlugin(const std::string& dataDir) : dataDir(dataDir) {}

    virtual std::string name() const override { return "UADE"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
	virtual std::vector<std::string> getSecondaryFiles(const std::string &file) override;
    virtual int priority() override { return -10; }

private:
    std::string dataDir;
};

} // namespace musix

