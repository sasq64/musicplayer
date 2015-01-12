#ifndef ADPLUGPLAYER_H
#define ADPLUGPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class AdPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "AdPlug"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // ADPLUGPLAYER_H