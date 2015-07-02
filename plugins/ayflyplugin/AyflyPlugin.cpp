
#include "AyflyPlugin.h"
#include "../../chipplayer.h"
#include <coreutils/utils.h>

#include "ayfly.h"

#include <set>

using namespace std;

namespace chipmachine {

class AyflyPlayer : public ChipPlayer {
public:
	AyflyPlayer(const string &fileName) : aysong(nullptr), started(false), ended(false) {


		aysong = ay_initsong(fileName.c_str(), 44100);
		const char *songName = ay_getsongname(aysong);
		const char *songAuthor = ay_getsongauthor(aysong);
		int len =  ay_getsonglength(&aysong) / 50;
		if(len > 1000) len = 0;
		 setMeta(
		 	"title", songName,
		 	"composer", songAuthor,
		 	"length",len
		);
	}
	~AyflyPlayer() override {
		if(aysong)
			ay_closesong(&aysong);
	}

	int getSamples(int16_t *target, int noSamples) override {
		int rc = ay_rendersongbuffer(aysong, (unsigned char*)target, noSamples);
		return rc/2;
	}

	virtual bool seekTo(int song, int seconds) override {
		return false;
	}

private:
	void *aysong;
	bool started;
	bool ended;
};

static const set<string> supported_ext = { "stp2", "ay", "psg", "asc", "stc", "psc", "sqt", "stp", "pt1", "pt2", "pt3", "ftc", "vtx", "vt2" };

bool AyflyPlugin::canHandle(const std::string &name) {
	return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *AyflyPlugin::fromFile(const std::string &name) {
	try {
		return new AyflyPlayer { name };
	} catch(player_exception &e) {
		return nullptr;
	}
};

} // namespace chipmachine
