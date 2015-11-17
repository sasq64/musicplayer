#ifndef MDX_PLAYER_H
#define MDX_PLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class MDXPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "MDX"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
	virtual std::vector<std::string> getSecondaryFiles(const std::string &name) override;
};

}

#endif // MDX_PLAYER_H
