
#include "AyflyPlugin.h"
#include "../../chipplayer.h"
#include <coreutils/utils.h>

#include "ayfly.h"

#include <set>

namespace musix {

class AyflyPlayer : public ChipPlayer {
public:
    AyflyPlayer(const std::string &fileName)
        : aysong(nullptr), started(false), ended(false) {

        aysong = ay_initsong(fileName.c_str(), 44100);
        if(!aysong)
            throw player_exception("Not any ay file");
        const char *songName = ay_getsongname(aysong);
        const char *songAuthor = ay_getsongauthor(aysong);
        unsigned long len = ay_getsonglength(aysong) / 50;
        if(len > 1000)
            len = 0;
        setMeta("title", songName, "composer", songAuthor, "length", len);
    }

    ~AyflyPlayer() override {
        if(aysong)
            ay_closesong(&aysong);
    }

    int getSamples(int16_t *target, int noSamples) override {
        int rc =
            ay_rendersongbuffer(aysong, (unsigned char *)target, noSamples);
        return rc / 2;
    }

    bool seekTo(int song, int seconds) override { return false; }

private:
    void *aysong;
    bool started;
    bool ended;
};

static const std::set<std::string> supported_ext = {
    "stp2", "ay",  "psg", "asc", "stc", "psc", "sqt",
    "stp",  "pt1", "pt2", "pt3", "ftc", "vtx", "vt2",
	"zxs", "st13"};

bool AyflyPlugin::canHandle(const std::string &name) {
    if(utils::toLower(name).find("/quartet") != std::string::npos)
        return false;
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *AyflyPlugin::fromFile(const std::string &name) {
    try {
        return new AyflyPlayer{name};
    } catch(player_exception &e) {
        return nullptr;
    }
};

} // namespace musix
