#pragma once

#include "../../chipplugin.h"

namespace musix {

class TEDPlugin : public ChipPlugin {
public:
    virtual std::string name() const override { return "Tedplay"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

