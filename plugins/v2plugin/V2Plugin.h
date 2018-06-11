#pragma once

#include "../../chipplugin.h"

namespace musix {

class V2Plugin : public ChipPlugin {
public:
    V2Plugin();
    virtual std::string name() const override { return "V2Plugin"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

