#pragma once

#include "../../chipplugin.h"

namespace musix {

class V2Plugin : public ChipPlugin
{
public:
    V2Plugin();
    std::string name() const override { return "V2Plugin"; }
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

