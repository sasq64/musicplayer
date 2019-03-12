#include <builders/residfp-builder/residfp.h>
#include <math.h>
#include <sidplayfp/SidInfo.h>
#include <sidplayfp/SidTune.h>
#include <sidplayfp/SidTuneInfo.h>
#include <sidplayfp/sidplayfp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef _WIN32
#    include <libgen.h>
#else
#    define strncasecmp _strnicmp
#    define strcasecmp _stricmp
#endif

#include "SidPlugin.h"

#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <set>

using namespace std;

namespace musix {

class SidPlayer : public ChipPlayer
{
public:
    SidPlayer(const string& fileName)
    {
        engine.setRoms(nullptr, nullptr, nullptr);

        rs = new ReSIDfpBuilder("musix");
        // Get the number of SIDs supported by the engine
        unsigned int max_sids = engine.info().maxsids();

        // Create SID emulators
        rs->create(max_sids);

        // Check if builder is ok
        if (!rs->getStatus()) {
            printf("SidPlugin error %s\n", rs->error());
            throw player_exception();
        }

        tune = new SidTune(fileName.c_str());

        // CHeck if the tune is valid
        if (!tune->getStatus()) {
            printf("SidPlugin: tune status %s\n", tune->statusString());
            throw player_exception();
        }

        // Select default song
        tune->selectSong(0);

        // Configure the engine
        SidConfig cfg;
        cfg.frequency = 44100;
        cfg.samplingMethod = SidConfig::INTERPOLATE;
        cfg.fastSampling = false;
        cfg.playback = SidConfig::MONO;
        cfg.sidEmulation = rs;
        cfg.defaultSidModel = SidConfig::MOS8580;

        if (!engine.config(cfg)) {
            printf("Engine error %s\n", engine.error());
            throw player_exception();
        }

        // Load tune into engine
        if (!engine.load(tune)) {
            printf("Engine error %s\n", engine.error());
            throw player_exception();
        }

	    const SidTuneInfo* info = tune->getInfo();
        std::string title = info->infoString(0);
        std::string composer = info->infoString(1);
        std::string copyright = info->infoString(1);

        setMeta("title", title, "composer", composer, "copyright", copyright,
                "startSong", info->startSong(), "song", info->startSong());
    }
    ~SidPlayer() override
    {
        engine.stop();
        delete rs;
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        int16_t temp_data[8192];

        int rc = engine.play(temp_data, noSamples/2);

        for (int i = 0; i < rc; ++i) {
            auto v = temp_data[i];
            target[i*2] = v;
            target[i*2+1] = v;
        }
        return rc*2;
    }

    virtual bool seekTo(int song, int seconds) override { return true; }

private:
    sidplayfp engine;
    ReSIDfpBuilder* rs = nullptr;
    SidTune* tune = nullptr;
};

static const set<string> supported_ext = {"sid"};

SidPlugin::SidPlugin(std::string const& condifDir) {}

bool SidPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* SidPlugin::fromFile(const std::string& name)
{
    try {
        return new SidPlayer{name};
    } catch (player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
