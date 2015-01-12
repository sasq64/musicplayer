#ifndef USFPLAYER_H
#define USFPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class USFPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "USFPlugin"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // USFPLAYER_H