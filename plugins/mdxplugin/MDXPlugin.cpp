
#include "MDXPlugin.h"
#include "../../chipplayer.h"
#include <coreutils/utils.h>

extern "C" {
#include "mdxmini.h"
}

#include <set>

using namespace std;

namespace chipmachine {

class MDXPlayer : public ChipPlayer {
public:
	MDXPlayer(const string &fileName) : started(false), ended(false) {

	using P = std::pair<uint16_t, uint32_t>;

		mdx_set_rate(44100);
 		if(mdx_open(&song, fileName.c_str(), utils::path_directory(fileName).c_str()))
 			throw player_exception();

		char title[1024];
		int len = mdx_get_length(&song);
		mdx_get_title(&song, title);

		char *ptr = title;
		while(*ptr) {
			if(*ptr > 0x7f)
				*ptr = ' ';
			ptr++;
		}

		 setMeta(
		 	"title", title,
		 	"length", len,
		 	"format", "MDX"
		);
	}
	~MDXPlayer() override {
		mdx_close(&song);
	}

	int getSamples(int16_t *target, int noSamples) override {
		int n = noSamples;
		int rc = mdx_calc_sample(&song, target, noSamples/2);
		return noSamples;
	}

	virtual bool seekTo(int song, int seconds) override {
		return false;
	}

private:
	t_mdxmini song;
	bool started;
	bool ended;
};

static const set<string> supported_ext = { "mdx" };

bool MDXPlugin::canHandle(const std::string &name) {
	return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *MDXPlugin::fromFile(const std::string &name) {
	try {
		return new MDXPlayer { name };
	} catch(player_exception &e) {
		return nullptr;
	}
};

} // namespace chipmachine
