#ifndef AYFLY_PLAYER_H
#define AYFLY_PLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class AyflyPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "Ayfly ZX"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // AYFLY_PLAYER_H