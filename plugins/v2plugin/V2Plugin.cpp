
#include "V2Plugin.h"

#include "v2mplayer.h"
#include "libv2.h"
#include "v2mconv.h"
#include "sounddef.h"

#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/utils.h>
#include <coreutils/file.h>

#include <set>
#include <array>

using namespace std;

namespace musix {

class V2Player : public ChipPlayer {
public:
    V2Player(const string& fileName) {

		auto data = utils::File { fileName }.readAll();

		int version = CheckV2MVersion(&data[0], data.size());
		if (version < 0)
			throw player_exception("Illegal version");

		int converted_length;
		ConvertV2M(&data[0], data.size(), &converted, &converted_length);
		if (converted == nullptr)
			throw player_exception("Could not convert");

		player.Init();
		player.Open(converted);

		player.Play();
		setMeta("length", player.Length());
    }

    ~V2Player() override {
		player.Close();
		if(converted)
			delete [] converted;
    }

    int getSamples(int16_t* target, int noSamples) override {

		player.Render(&temp[0], noSamples/2);
		for(int i=0; i<noSamples; i++) {
			target[i] = temp[i] * scaler; // NOTE: Should really be normalized, values usually < 2.0 though
		}
		return noSamples;
    }

    virtual bool seekTo(int song, int seconds) override { return true; }

private:
	std::array<float, 150000> temp;
	V2MPlayer player;
	uint8_t* converted = nullptr;
	float scaler = 10000.0;
};

static const set<string> supported_ext = {"v2", "v2m"};

V2Plugin::V2Plugin() {
	sdInit();
}

bool V2Plugin::canHandle(const std::string& name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* V2Plugin::fromFile(const std::string& name) {
    try {
        return new V2Player{name};
    } catch(player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
