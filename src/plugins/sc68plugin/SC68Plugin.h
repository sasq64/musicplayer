#ifndef SC68PLAYER_H
#define SC68PLAYER_H

#include "../../chipplugin.h"

namespace musix {

class SC68Plugin : public ChipPlugin {
public:
    std::string name() const override { return "SC68"; }
    explicit SC68Plugin(const std::string& dataDir) : dataDir(dataDir) {}
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;

private:
    std::string dataDir;
};

} // namespace musix

#endif // SC68PLAYER_H
