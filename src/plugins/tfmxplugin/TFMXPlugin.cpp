#include <cstdint>

extern "C"
{
#include "player.h"
    int load_tfmx(const char* mfn, const char* sfn);
    void TfmxInit();
    void StartSong(int, int);
    int available_sound_data();
    int try_to_makeblock();
    void open_sndfile();
    extern struct Hdb hdb[8];
    extern int LoopOff(/* struct Hdb *hw */);
    int read_data(int16_t* target, int size);
}

#include "TFMXPlugin.h"

#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>

#include <set>

namespace musix {

class TFMXPlayer : public ChipPlayer
{
public:
    explicit TFMXPlayer(std::string const& fileName)
    {
        auto sampleFile = "smpl." + fileName.substr(5);

        LOGI("Loading");
        auto rc = load_tfmx(fileName.c_str(), sampleFile.c_str());
        if (rc != 0) {
            LOGE("RC {}", rc);
            throw player_exception();
        }

        TfmxInit();
        int songnum = 0;
        StartSong(songnum, 0);
        open_sndfile();
        hdb[0] = (struct Hdb){0,
                              0x1C01,
                              0x3200,
                              0x15BE,
                              (char*)&smplbuf[0x4],
                              (char*)&smplbuf[0x4 + 0x1C42],
                              0x40,
                              3,
                              &LoopOff,
                              0,
                              NULL};

        //        setMeta("title", tune->ht_Name, "message", msg, "channels",
        //                tune->ht_Channels, "length", tune->ht_PlayingTime,
        //                "format", tune->ht_Version == 0xAA ? "AHX" : "TFMX");
    }

    ~TFMXPlayer() override = default;

    int getHZ() override { return outRate / 2; }

    int getSamples(int16_t* target, int noSamples) override
    {
        // uint8_t temp[256*1024];
        read_data(target, noSamples);
        // for (int i=0; i<noSamples; i++) {
        //     target[i] = temp[i] <<7;
        // }
        return noSamples;
    }

    bool seekTo(int song, int /*seconds*/) override
    {
        StartSong(song, 0);
        open_sndfile();
        hdb[0] = (struct Hdb){0,
                              0x1C01,
                              0x3200,
                              0x15BE,
                              (char*)&smplbuf[0x4],
                              (char*)&smplbuf[0x4 + 0x1C42],
                              0x40,
                              3,
                              &LoopOff,
                              0,
                              NULL};
        return true;
    }

private:
};

TFMXPlugin::TFMXPlugin() = default;

bool TFMXPlugin::canHandle(const std::string& name)
{
    return utils::startsWith(name, "mdat.");
    // return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* TFMXPlugin::fromFile(const std::string& name)
{
    return new TFMXPlayer{name};
};

} // namespace musix
