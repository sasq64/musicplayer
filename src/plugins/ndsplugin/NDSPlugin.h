#ifndef NDSPLAYER_H
#define NDSPLAYER_H

#include "../../chipplugin.h"

namespace musix {

class NDSPlugin : public ChipPlugin {
public:
    virtual std::string name() const override { return "NDSPlugin"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

#endif // NDSPLAYER_H