#ifndef MDX_PLAYER_H
#define MDX_PLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class MDXPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "MDX"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // MDX_PLAYER_H