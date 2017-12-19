#ifndef HIVELY_PLAYER_H
#define HIVELY_PLAYER_H

#include "../../chipplugin.h"

namespace musix {

class HivelyPlugin : public ChipPlugin {
public:
    HivelyPlugin();
    virtual std::string name() const override { return "HivelyPlugin"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

#endif // HIVELY_PLAYER_H