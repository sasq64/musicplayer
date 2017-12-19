#pragma once

#include "../../chipplugin.h"

namespace musix {

class SexyPSFPlugin : public ChipPlugin {
public:
    virtual std::string name() const override { return "SexyPSF"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& name) override;
};

} // namespace musix

