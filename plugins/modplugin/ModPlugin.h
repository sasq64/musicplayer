#ifndef MODPLAYER_H
#define MODPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class ModPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "ModPlug"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // MODPLAYER_H