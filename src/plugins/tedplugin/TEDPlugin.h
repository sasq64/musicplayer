#pragma once

#include "../../chipplugin.h"

namespace musix {

class TEDPlugin : public ChipPlugin
{
public:
    std::string name() const override { return "Tedplay"; }
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

