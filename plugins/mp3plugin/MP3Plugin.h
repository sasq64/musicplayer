#pragma once

#include "../../chipplugin.h"

namespace musix {

class MP3Plugin : public ChipPlugin {
public:
    virtual std::string name() const override { return "libmpg123"; }
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;
    virtual ChipPlayer*
    fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo) override;
};

} // namespace musix

