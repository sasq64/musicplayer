#ifndef FFMPEGPLAYER_H
#define FFMPEGPLAYER_H

#include "../../chipplugin.h"

namespace chipmachine {

class FFMPEGPlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "ffmpeg"; }
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;
	virtual ChipPlayer *fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo) override;
	virtual bool checkSilence() const override { return false; }
};

}

#endif // FFMPEGPLAYER_H
