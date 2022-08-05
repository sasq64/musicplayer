#pragma once

#include "../../chipplugin.h"

namespace musix {

class GMEPlugin : public ChipPlugin {
public:
    virtual std::string name() const override { return "Game Music Engine"; }
    virtual bool canHandle(const std::string &name) override;
    virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

} // namespace musix
