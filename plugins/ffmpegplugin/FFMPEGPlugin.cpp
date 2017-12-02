
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
	FFMPEGPlayer(const std::string &ffmpeg) {
	}

	FFMPEGPlayer(const std::string &fileName, const std::string &ffmpeg) {
		pipe = std::move(execPipe(utils::format("%s -i \"%s\" -v error -ac 2 -ar 44100 -f s16le -", ffmpeg, fileName)));
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

FFMPEGPlugin::FFMPEGPlugin() {
#ifdef _WIN32
	ffmpeg = "bin\\ffmpeg.exe";
#else
	auto xd = File::getExeDir();
	string path = File::makePath({xd.resolve(), (xd / ".." / ".." / "bin").resolve()});
	LOGD("PATH IS '%s'", path);
	ffmpeg = File::findFile(path, "ffmpeg");
	if(ffmpeg == "")
		ffmpeg = "ffmpeg";
#endif
	LOGD("FFMPEG IS '%s'", ffmpeg);
}

bool FFMPEGPlugin::canHandle(const std::string &name) {
	auto ext = utils::path_extension(name);
	return ext == "m4a" || ext == "aac";
}

ChipPlayer *FFMPEGPlugin::fromFile(const std::string &fileName) {
	return new FFMPEGPlayer{fileName, ffmpeg};
};

ChipPlayer *FFMPEGPlugin::fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo) {
	return new FFMPEGPlayer(ffmpeg);
}
}
