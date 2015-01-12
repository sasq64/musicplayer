#ifndef STPLAYER_H
#define STPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class StSoundPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "StSound"; }

	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // STPLAYER_H