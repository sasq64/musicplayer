#pragma once

#include "../../chipplugin.h"

namespace musix {

class FFMPEGPlugin : public ChipPlugin {
public:
    FFMPEGPlugin();
    virtual std::string name() const override { return "ffmpeg"; }
    virtual bool canHandle(const std::string &name) override;
    virtual ChipPlayer *fromFile(const std::string &fileName) override;
    virtual ChipPlayer *
    fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo) override;
    virtual bool checkSilence() const override { return false; }

private:
    std::string ffmpeg;
};

} // namespace musix
