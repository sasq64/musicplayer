extern "C"
{
#include "hvl_replay.h"
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
	    auto rc = load_tfmx(mfn,sfn);
        if (rc != 0) {
            throw player_exception();
        }

        TfmxInit();
        StartSong(songnum,0);

        setMeta("title", tune->ht_Name, "message", msg, "channels",
                tune->ht_Channels, "length", tune->ht_PlayingTime, "format",
                tune->ht_Version == 0xAA ? "AHX" : "TFMX");
    }

    ~TFMXPlayer() override
    {
    }

    int getSamples(int16_t* target, int noSamples) override
    {

        const int frameSize = ((44100 * 2) / 50);

        auto* ptr = reinterpret_cast<int8_t*>(target);
        int len = 0;
        while (len < noSamples - frameSize) {
            hvl_DecodeFrame(tune, ptr, ptr + 2, 4);
            ptr += frameSize * 2;
            len += frameSize;
        }
        return len;
    }

    bool seekTo(int /*song*/, int /*seconds*/) override { return true; }

private:
    struct hvl_tune* tune;
};

static const std::set<std::string> supported_ext = {"ahx", "hvl"};

TFMXPlugin::TFMXPlugin()
{
    hvl_InitReplayer();
}

bool TFMXPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* TFMXPlugin::fromFile(const std::string& name)
{
    try {
        return new TFMXPlayer{name};
    } catch (player_exception const& e) {
        return nullptr;
    }
};

} // namespace musix
