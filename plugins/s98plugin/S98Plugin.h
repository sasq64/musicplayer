#ifndef S98_PLAYER_H
#define S98_PLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class S98Plugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "S98"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // S98_PLAYER_H