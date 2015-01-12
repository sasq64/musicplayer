
#include "TEDPlugin.h"
#include "../../chipplayer.h"
#include <coreutils/utils.h>

#include "tedplay/tedplay.h"

#include <set>

using namespace std;

namespace chipmachine {

class PluginAudio : public Audio {

};

class TEDPlayer : public ChipPlayer {
public:
	TEDPlayer(const string &fileName)  {

		setMeta(
			// "game", track0->game,
			// "composer", track0->author,
			// "copyright", track0->copyright,
			// "length", track0->length > 0 ? track0->length / 1000 : 0,
			// "sub_title", track0->song,
			// "format", track0->system,
			// "songs", gme_track_count(emu)
		);
	}
	~TEDPlayer() override {
	}

	int getSamples(int16_t *target, int noSamples) override {
	}

	virtual bool seekTo(int song, int seconds) override {
		return true;
	}

private:
};

static const set<string> supported_ext = { "emul", "spc", "gym", "nsf", "nsfe", "gbs", "ay", "sap", "vgm", "vgz", "hes", "kss" };

bool TEDPlugin::canHandle(const std::string &name) {
	return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *TEDPlugin::fromFile(const std::string &name) {
	try {
		return new TEDPlayer { name };
	} catch(player_exception &e) {
		return nullptr;
	}
};

} // namespace chipmachine
