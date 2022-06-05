#include <builders/residfp-builder/residfp.h>

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>

#include <STIL.hpp>

#include <sidplayfp/SidInfo.h>
#include <sidplayfp/SidTune.h>
#include <sidplayfp/SidTuneInfo.h>
#include <sidplayfp/sidplayfp.h>

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

namespace musix {

class SidPlayer : public ChipPlayer
{
public:
    explicit SidPlayer(const std::string& fileName, STIL* stil)
    {

        engine.setRoms(nullptr, nullptr, nullptr);

        rs = std::make_unique<ReSIDfpBuilder>("musix");
        // Get the number of SIDs supported by the engine
        auto max_sids = engine.info().maxsids();

        // Create SID emulators
        rs->create(max_sids);

        // Check if builder is ok
        if (!rs->getStatus()) {
            printf("SidPlugin error %s\n", rs->error());
            throw player_exception();
        }

        tune = std::make_unique<SidTune>(fileName.c_str());

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
        cfg.sidEmulation = rs.get();
        cfg.defaultSidModel = SidConfig::MOS8580;

        if (!engine.config(cfg)) {
            printf("Engine error %s\n", engine.error());
            throw player_exception();
        }

        // Load tune into engine
        if (!engine.load(tune.get())) {
            printf("Engine error %s\n", engine.error());
            throw player_exception();
        }
        auto key = STIL::calculateMD5(fileName);
        lengths = stil->findLengths(key);
        auto stilInfo = stil->findSTIL(fileName);

        const SidTuneInfo* info = tune->getInfo();
        auto&& title = info->infoString(0);
        auto&& composer = info->infoString(1);
        auto&& copyright = info->infoString(2);

        auto startSong = info->startSong();
        printf("%d/%d\n", startSong, info->songs());

        auto length = lengths.empty() ? 0 : lengths[startSong-1];


        setMeta("title", title, "composer", composer, "copyright", copyright,
                "startSong", info->startSong(), "song", startSong-1, "length", length);

        if (stilInfo) {
            setMeta("sub_title", stilInfo->songs[startSong-1].title);
        }
    }
    ~SidPlayer() override
    {
        engine.stop();
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        std::array<int16_t,8192> temp_data;

        auto rc = engine.play(temp_data.data(), noSamples / 2);

        for (int i = 0; i < rc; ++i) {
            auto v = temp_data[i];
            target[i * 2] = v;
            target[i * 2 + 1] = v;
        }
        return rc * 2;
    }

     bool seekTo(int song, int  /*seconds*/) override {
        tune->selectSong(song+1);
        engine.load(tune.get());
        printf("SONG %d\n", song);
        setMeta("length", lengths.empty() ? 0 : lengths[song], "song", song+1);
        return true; 
    }

private:
    std::vector<uint16_t> lengths; 
    sidplayfp engine;
    std::unique_ptr<ReSIDfpBuilder> rs;
    std::unique_ptr<SidTune> tune;
};

static const std::set<std::string> supported_ext = {"sid"};

SidPlugin::SidPlugin(std::string const& configDir) {

    stil = std::make_unique<STIL>(fs::path(configDir));
    initThread = std::thread([=] {
        stil->readLengths();
        stil->readSTIL();
    });

}

bool SidPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* SidPlugin::fromFile(const std::string& name)
{
    if (initThread.joinable()) { initThread.join(); }
    try {
        return new SidPlayer{name, stil.get()};
    } catch (player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
