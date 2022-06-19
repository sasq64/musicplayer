extern "C"
{
#include "hvl_replay.h"
}

#include "HivelyPlugin.h"

#include <coreutils/utf8.h>
#include <coreutils/utils.h>

#include <set>

namespace musix {

class HivelyPlayer : public ChipPlayer
{
public:
    explicit HivelyPlayer(std::string const& fileName)
        : tune(hvl_LoadTune(fileName.c_str(), 44100, 0), &hvl_FreeTune)
    {
        if (tune == nullptr) {
            throw player_exception();
        }
        std::string msg;
        for (auto i = 1; i < tune->ht_InstrumentNr; i++) {
            auto const* name = tune->ht_Instruments[i].ins_Name;
            msg = msg + utils::utf8_encode(name) + " ";
        }

        setMeta("title", tune->ht_Name, "message", msg, "channels",
                tune->ht_Channels, "length", tune->ht_PlayingTime, "format",
                tune->ht_Version == 0xAA ? "AHX" : "Hively");
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        const int frameSize = ((44100 * 2) / 50);

        auto* ptr = reinterpret_cast<int8_t*>(target);
        int len = 0;
        while (len < noSamples - frameSize) {
            hvl_DecodeFrame(tune.get(), ptr, ptr + 2, 4);
            ptr += frameSize * 2;
            len += frameSize;
        }
        return len;
    }

    bool seekTo(int /*song*/, int /*seconds*/) override { return true; }

private:
    std::shared_ptr<hvl_tune> tune;
};

static const std::set<std::string> supported_ext = {"ahx", "hvl"};

HivelyPlugin::HivelyPlugin()
{
    hvl_InitReplayer();
}

bool HivelyPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* HivelyPlugin::fromFile(const std::string& name)
{
    return new HivelyPlayer{name};
};

} // namespace musix
