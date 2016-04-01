#ifndef TED_PLAYER_H
#define TED_PLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class TEDPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "Tedplay"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // TED_PLAYER_H