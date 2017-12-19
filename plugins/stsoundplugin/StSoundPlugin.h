#ifndef STPLAYER_H
#define STPLAYER_H

#include "../../chipplugin.h"

namespace musix {

class StSoundPlugin : public ChipPlugin {
public:
    virtual std::string name() const override { return "StSound"; }

    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
};

} // namespace musix

#endif // STPLAYER_H