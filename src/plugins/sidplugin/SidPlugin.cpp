#include "SidPlugin.h"
#include <chrono>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>

#include "kernal.h"
#include "chargen.h"
#include "basic.h"

#include <STIL.hpp>

#include <builders/residfp-builder/residfp.h>
#include <filesystem>
#include <sidplayfp/SidInfo.h>
#include <sidplayfp/SidTune.h>
#include <sidplayfp/SidTuneInfo.h>
#include <sidplayfp/sidplayfp.h>

#include <cstdio>
#include <memory>
#include <string>
#include <thread>

using namespace std::string_literals;

#ifndef _WIN32
#    include <libgen.h>
#else
#    define strncasecmp _strnicmp
#    define strcasecmp _stricmp
#endif

#include <set>

namespace musix {

class SidPlayer : public ChipPlayer
{
public:
    explicit SidPlayer(std::string const& fileName, SidPlugin* plugin)
    {
        stil = plugin->stil.get();
        engine.setRoms(kernal, chargen, basic);

        rs = std::make_unique<ReSIDfpBuilder>("musix");
        // Get the number of SIDs supported by the engine
        auto max_sids = engine.info().maxsids();

        // Create SID emulators
        rs->create(max_sids);

        // Check if builder is ok
        if (!rs->getStatus()) {
            throw player_exception("SidPlugin error"s + rs->error());
        }

        tune = std::make_unique<SidTune>(fileName.c_str());

        // CHeck if the tune is valid
        if (!tune->getStatus()) {
            throw player_exception("SidPlugin: tune status: "s +
                                   tune->statusString());
        }

        // Select default song
        tune->selectSong(0);

        // Configure the engine
        SidConfig cfg{};
        cfg.frequency = 44100;
        cfg.samplingMethod = SidConfig::INTERPOLATE;
        cfg.fastSampling = false;
        cfg.playback = SidConfig::MONO;
        cfg.sidEmulation = rs.get();
        cfg.defaultSidModel = SidConfig::MOS8580;

        if (!engine.config(cfg)) {
            throw player_exception("SidPlugin engine error: "s +
                                   engine.error());
        }

        const SidTuneInfo* info = tune->getInfo();

        auto title = utils::utf8_encode(info->infoString(0));
        auto composer = utils::utf8_encode(info->infoString(1));
        auto copyright = utils::utf8_encode(info->infoString(2));

        auto startSong = info->startSong() - 1;

        tune->selectSong(startSong + 1);
        // Load tune into engine
        if (!engine.load(tune.get())) {
            printf("Engine error %s\n", engine.error());
            throw player_exception();
        }
        song_data = utils::read_file(fileName);
        if (stil != nullptr && stil->ready) {
            stilInfo = stil->getInfo(song_data);
        }

        lengths = stilInfo.lengths;
        auto length = lengths.empty() ? 0 : lengths[startSong];

        setMeta("title", title, "composer", composer, "copyright", copyright,
                "format", "SID (C64)", "startSong", startSong, "song",
                startSong, "length", length, "songs", info->songs());

        current_song = startSong;
        if (!stilInfo.comment.empty()) { setMeta("comment", stilInfo.comment); }
        updateSongMeta(startSong);
    }

    ~SidPlayer() override { engine.stop(); }

    void updateSongMeta(int song)
    {
        std::string sub;
        if (!stilInfo.songs.empty()) {
            for (auto const& songInfo : stilInfo.songs) {
                if (songInfo.subSong == song + 1) {
                    sub = songInfo.name;
                    if (sub.empty()) {
                        sub = songInfo.title;
                        if (!sub.empty() && !songInfo.artist.empty()) {
                            sub += " / " + songInfo.artist;
                        }
                    }
                    if (sub.empty()) { sub = songInfo.comment; }
                }
            }
        }
        setMeta("sub_title", sub);
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        if (delay > 0 && stil != nullptr && stil->ready) {
            delay--;
            if (delay == 1) {
                stilInfo = stil->getInfo(song_data);
            } else if (delay == 0) {
                lengths = stilInfo.lengths;
                auto length = lengths.empty() ? 0 : lengths[current_song];
                setMeta("length", length);
                if (!stilInfo.comment.empty()) { setMeta("comment", stilInfo.comment); }
                updateSongMeta(current_song);
            }
        }
        std::array<int16_t, 8192> temp_data;

        auto rc = engine.play(temp_data.data(), noSamples / 2);

        for (int i = 0; i < rc; ++i) {
            auto v = temp_data[i];
            target[i * 2] = v;
            target[i * 2 + 1] = v;
        }
        return static_cast<int>(rc) * 2;
    }

    bool seekTo(int song, int /*seconds*/) override
    {
        current_song = song;
        tune->selectSong(song + 1);
        engine.load(tune.get());
        setMeta("length", lengths.empty() ? 0 : lengths[song], "song", song);
        updateSongMeta(song);
        return true;
    }

private:
    STIL* stil;
    int delay = 10;
    int current_song;
    std::vector<uint8_t> song_data;
    std::vector<uint16_t> lengths;
    sidplayfp engine;
    std::unique_ptr<ReSIDfpBuilder> rs;
    std::unique_ptr<SidTune> tune;
    STIL::STILSong stilInfo;
};

static const std::set<std::string> supported_ext = {"sid", "psid"};

SidPlugin::~SidPlugin()
{
    if (initThread.joinable()) { initThread.join(); }
};

bool SidPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* SidPlugin::fromFile(const std::string& name)
{
    fs::path p = name;

    if (stil == nullptr) {
        p = p.parent_path();
        while (p.has_relative_path() && fs::exists(p)) {
            auto stilPath = p / "DOCUMENTS";
            if (fs::exists(stilPath / "STIL.txt")) {
                stil = std::make_unique<STIL>(stilPath);
                initThread = std::thread([=] {
                    stil->readSTIL();
                    stil->readLengths();
                    stil->ready = true;
                });
                break;
            }
            p = p.parent_path();
        }
    }
    if (stil != nullptr && stil->ready && initThread.joinable()) {
       initThread.join(); 
    }

    return new SidPlayer{name, this};
};

} // namespace musix

extern "C" void sidplugin_register()
{
    musix::ChipPlugin::addPluginConstructor([](std::string const& config) {
        return std::make_shared<musix::SidPlugin>();
    });
}
