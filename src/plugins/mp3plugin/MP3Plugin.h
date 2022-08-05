#pragma once

#include "../../chipplugin.h"

namespace musix {

class MP3Plugin : public ChipPlugin
{
public:
    std::string name() const override { return "libmpg123"; }
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;
    ChipPlayer* fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo) override;
};

} // namespace musix

