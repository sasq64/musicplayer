#ifndef HTPLAYER_H
#define HTPLAYER_H

#include "../../chipplugin.h"

namespace musix {

class HTPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "HTPlugin"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
};

}

#endif // HTPLAYER_H