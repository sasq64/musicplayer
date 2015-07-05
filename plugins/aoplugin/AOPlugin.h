#ifndef  AO_PLAYER_H
#define  AO_PLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class AOPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "Audio Overload"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // AO_PLAYER_H