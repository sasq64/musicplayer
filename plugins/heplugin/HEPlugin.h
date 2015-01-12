#ifndef HEPLAYER_H
#define HEPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class HEPlugin : public ChipPlugin {
public:
	HEPlugin(const std::string &biosFileName) : biosFileName(biosFileName) {}
	virtual std::string name() const override { return "HEPlugin"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
private:
	std::string biosFileName;
	bool biosLoaded = false;
};

}

#endif // HEPLAYER_H