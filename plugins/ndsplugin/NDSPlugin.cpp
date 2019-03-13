
#include "NDSPlugin.h"
#include <psf/PSFFile.h>
#include <coreutils/utils.h>
#include <set>
#include <string.h>

#include "nds/vio2sf/vio2sf.h"

using namespace std;

namespace musix {

class NDSPlayer : public ChipPlayer {
public:
    NDSPlayer(const std::string& fileName) {
        int result = xsf_start((char*)fileName.c_str());

        if(!result)
            throw player_exception();

        PSFFile psf{fileName};
        if(psf.valid()) {
            auto& tags = psf.tags();

            int seconds = psf.songLength();

            setMeta("composer", tags["artist"], "sub_title", tags["title"],
                    "game", tags["game"], "format", "Nintendo DS", "length",
                    seconds);
        }
    }

    ~NDSPlayer() { xsf_term(); }

    virtual int getSamples(int16_t* target, int noSamples) override {
        int ret = xsf_gen(target, noSamples / 2);
        return noSamples;
    }
};

static const set<string> supported_ext{"2sf", "mini2sf"};

bool NDSPlugin::canHandle(const std::string& name) {
    auto ext = utils::path_extension(name);
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* NDSPlugin::fromFile(const std::string& fileName) {
    try {
        return new NDSPlayer{fileName};
    } catch(player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
