#ifndef TFMX_PLAYER_H
#define TFMX_PLAYER_H

#include "../../chipplugin.h"

namespace musix {

class TFMXPlugin : public ChipPlugin
{
public:
    TFMXPlugin();
    std::string name() const override { return "TFMXPlugin"; }
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

#endif // TFMX_PLAYER_H
