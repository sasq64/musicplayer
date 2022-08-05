#pragma once

#include "../../chipplugin.h"

namespace musix {

class MDXPlugin : public ChipPlugin {
public:
    virtual std::string name() const override { return "MDX"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
    virtual std::vector<std::string>
    getSecondaryFiles(const std::string& name) override;
};

} // namespace musix

