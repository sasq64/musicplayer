extern "C" {
#include "hvl_replay.h"
}

#include "HivelyPlugin.h"

#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <set>

using namespace std;

namespace musix {

class HivelyPlayer : public ChipPlayer {
public:
    HivelyPlayer(const string& fileName) {

        tune = hvl_LoadTune(fileName.c_str(), 44100, 0);

        if(!tune)
            throw player_exception();
        string msg;
        for(int i = 1; i < tune->ht_InstrumentNr; i++) {
            char* name = tune->ht_Instruments[i].ins_Name;
            msg = msg + utils::utf8_encode(name) + " ";
        }

        setMeta("title", tune->ht_Name, "message", msg, "channels",
                tune->ht_Channels, "length", tune->ht_PlayingTime, "format",
                tune->ht_Version == 0xAA ? "AHX" : "Hively");
    }
    ~HivelyPlayer() override {
        hvl_FreeTune(tune);
        tune = nullptr;
    }

    int getSamples(int16_t* target, int noSamples) override {

        const int frameSize = ((44100 * 2) / 50);

        int8_t* ptr = (int8_t*)target;
        int len = 0;
        while(len < noSamples - frameSize) {
            hvl_DecodeFrame(tune, ptr, ptr + 2, 4);
            ptr += frameSize * 2;
            len += frameSize;
        }
        return len;
    }

    virtual bool seekTo(int song, int seconds) override { return true; }

private:
    struct hvl_tune* tune;
};

static const set<string> supported_ext = {"ahx", "hvl"};

HivelyPlugin::HivelyPlugin() {
    hvl_InitReplayer();
}

bool HivelyPlugin::canHandle(const std::string& name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* HivelyPlugin::fromFile(const std::string& name) {
    try {
        return new HivelyPlayer{name};
    } catch(player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
