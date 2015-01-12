#ifndef GSFPLAYER_H
#define GSFPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class GSFPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "GSFPlugin"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // GSFPLAYER_H