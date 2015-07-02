
#include "S98Plugin.h"
#include "../../chipplayer.h"
#include <coreutils/utils.h>
#include <coreutils/file.h>

#include "m_s98.h"

#include <set>

using namespace std;

namespace chipmachine {

class S98Player : public ChipPlayer {
public:
	S98Player(const string &fileName) : started(false), ended(false) {

		auto buffer = utils::File(fileName).readAll();

		if(!song.OpenFromBuffer(&buffer[0], buffer.size()))
			throw player_exception();

		// int len = 0;
		// if(len > 1000) len = 0;
		//  setMeta(
		//  	"title", songName,
		//  	"composer", songAuthor,
		//  	"length",len
		// );
	}
	~S98Player() override {
	}

	int getSamples(int16_t *target, int noSamples) override {
		int rc = song.Write(target, noSamples/2);
		return rc*2;
	}

	virtual bool seekTo(int song, int seconds) override {
		return false;
	}

private:
	s98File song;
	bool started;
	bool ended;
};

static const set<string> supported_ext = { "s98" };

bool S98Plugin::canHandle(const std::string &name) {
	return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *S98Plugin::fromFile(const std::string &name) {
	try {
		return new S98Player { name };
	} catch(player_exception &e) {
		return nullptr;
	}
};

} // namespace chipmachine
