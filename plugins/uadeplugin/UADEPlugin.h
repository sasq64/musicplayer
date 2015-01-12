#ifndef UADEPLUGIN_H
#define UADEPLUGIN_H

#include "../../chipplugin.h"

namespace chipmachine {

class UADEPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "UADE"; }
	//UADEPlugin();
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;

	virtual int priority() { return -10; }
};

}

#endif // UADEPLUGIN_H