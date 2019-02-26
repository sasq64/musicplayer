
#include "GMEPlugin.h"
#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/utils.h>
#include <coreutils/ptr.h>

#include "gme/gme.h"

#include <set>

namespace musix {

class GMEPlayer : public ChipPlayer
{
public:
    GMEPlayer(const std::string& fileName) : started(false), ended(false)
    {
        gme_err_t err = gme_open_file(fileName.c_str(), &utils::raw_ptr(emu), 44100);
        if (err) throw player_exception("Could not load GME music");

        gme_info_t* track0;

        gme_track_info(emu.get(), &track0, 0);

        setMeta("game", track0->game, "composer", track0->author, "copyright",
                track0->copyright, "length",
                track0->length > 0 ? track0->length / 1000 : 0, "sub_title",
                track0->song, "format", track0->system, "songs",
                gme_track_count(emu.get()));
        gme_free_info(track0);
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        gme_err_t err;
        if (!started) {
            err = gme_start_track(emu.get(), 0);
            started = true;
        }

        if (!ended && gme_track_ended(emu.get())) {
            LOGD("## GME HAS ENDED");
            ended = true;
        }
        if (ended) {
            memset(target, 0, noSamples * 2);
            return noSamples;
        }

        err = gme_play(emu.get(), noSamples, target);

        return noSamples;
    }

    virtual bool seekTo(int song, int seconds) override
    {
        if (song >= 0) {

            if (ended) {
                // err = gme_start_track(emu, 0);
                ended = false;
            }

            gme_info_t* track;
            gme_track_info(emu.get(), &track, song);
            setMeta("sub_title", track->song, "length",
                    track->length > 0 ? track->length / 1000 : 0);

            gme_start_track(emu.get(), song);
            started = true;
            gme_free_info(track);
        }
        if (seconds >= 0) gme_seek(emu.get(), seconds);
        return true;
    }

private:
    std::unique_ptr<Music_Emu, void (*)(Music_Emu*)> emu{ nullptr, gme_delete };
    bool started;
    bool ended;
};

static const std::set<std::string> supported_ext = { "emul", "spc",  "gym",
                                                     "nsf",  "nsfe", "gbs",
                                                     "ay",   "sap",  "vgm",
                                                     "vgz",  "hes",  "kss" };

bool GMEPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* GMEPlugin::fromFile(const std::string& name)
{
    try {
        return new GMEPlayer{ name };
    } catch (player_exception& e) {
        LOGW("Failed");
        return nullptr;
    }
};

} // namespace musix
