
#include "FFMPEGPlugin.h"
#include "../../chipplayer.h"

#include <coreutils/utils.h>
#include <coreutils/file.h>
#include <coreutils/format.h>

#include <set>
#include <unordered_map>

using namespace std;
using namespace utils;

namespace chipmachine {

class FFMPEGPlayer : public ChipPlayer {
public:
	FFMPEGPlayer() {
	}

	FFMPEGPlayer(const std::string &fileName) {
#ifdef _WIN32
		pipe = std::move(execPipe(utils::format("bin\\ffmpeg.exe -i \"%s\" -v error -ac 2 -ar 44100 -f s16le -", fileName)));
#else
		pipe = std::move(execPipe(utils::format("ffmpeg -i \"%s\" -v error -ac 2 -ar 44100 -f s16le -", fileName)));
#endif
	}

	~FFMPEGPlayer() override {
		pipe.Kill();
	}

	virtual int getSamples(int16_t *target, int noSamples) override {
		int rc = pipe.read(reinterpret_cast<uint8_t*>(target), noSamples*2);
		if(rc == -1) return 0;
		return rc/2;
	}

	virtual bool seekTo(int song, int seconds) override { return false; }

private:
	ExecPipe pipe;
};

bool FFMPEGPlugin::canHandle(const std::string &name) {
	auto ext = utils::path_extension(name);
	return ext == "m4a" || ext == "aac";
}

ChipPlayer *FFMPEGPlugin::fromFile(const std::string &fileName) {
	return new FFMPEGPlayer{fileName};
};

ChipPlayer *FFMPEGPlugin::fromStream() {
	return new FFMPEGPlayer();
}
}
