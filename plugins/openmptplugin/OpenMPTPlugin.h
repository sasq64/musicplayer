#ifndef OPENMPTPLAYER_H
#define OPENMPTPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class OpenMPTPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "OpenMPT"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // OPENMPTPLAYER_H