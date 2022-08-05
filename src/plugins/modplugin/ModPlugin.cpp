
#include "ModPlugin.h"
#include "../../chipplayer.h"
#include "modplug.h"

#include <coreutils/file.h>
#include <coreutils/utils.h>
#include <set>
#include <unordered_map>

using namespace std;

namespace musix {

const static vector<string> format_names = {
    "ProTracker/NoiseTracker (MOD/FT)",
    "ScreamTracker 3 (S3M)",
    "FastTracker (XM)",
    "OctaMED (MED)",
    "MultiTracker (MTM)",
    "Impulse Tracker (Project) (IT / ITP)",
    "Composer 669 / UNIS 669 (669)",
    "UltraTracker (ULT)",
    "ScreamTracker 2 (STM)",
    "Farandole Composer (FAR)",
    "Windows (WAV)",
    "ASYLUM Music Format / DSMI Advanced Music Format (AMF)",
    "Extreme's Tracker / Velvet Studio (AMS)",
    "DSIK Format (DSM)",
    "DigiTrakker (MDL)",
    "Oktalyzer (OKT)",
    "Midi (MID)",
    "X-Tracker (DMF)",
    "PolyTracker (PTM)",
    "Digi Booster Pro (DBM)",
    "MadTracker 2 (MT2)",
    "AMF0",
    "Epic Megagames MASI (PSM)",
    "Jazz Jackrabbit 2 Music (J2B)",
    "ABC",
    "PAT",
    "UNKNOWN"
    //"Unreal Music Package (UMX)"
};

/*
Digi Booster (DIGI)
General Digital Music (GDM)
Imago Orpheus (IMF)
SoundTracker and compatible (M15 / STK)
MO3 compressed modules (MO3)
OpenMPT (MPTM)
Grave Composer (WOW)
*/

class ModPlayer : public ChipPlayer {
public:
    ModPlayer(uint8_t* data, uint64_t size) {

        ModPlug_Settings settings;
        ModPlug_GetSettings(&settings);
        settings.mChannels = 2;
        settings.mFrequency = 44100;
        settings.mBits = 16;
        settings.mLoopCount = -1;
        ModPlug_SetSettings(&settings);
        mod = ModPlug_Load(data, size);

        int type = ModPlug_GetModuleType(mod);
        unsigned int fmt = 0;
        while(type > 1 && fmt < format_names.size() - 1) {
            type >>= 1;
            fmt++;
        }

        setMeta("title", ModPlug_GetName(mod), "length",
                ModPlug_GetLength(mod) / 1000, "format", format_names[fmt]);
    }
    ~ModPlayer() override {
        if(mod)
            ModPlug_Unload(mod);
    }

    virtual int getSamples(int16_t* target, int noSamples) override {
        return ModPlug_Read(mod, (void*)target, noSamples * 2) / 2;
    }

    virtual bool seekTo(int song, int seconds) {
        if(mod)
            ModPlug_Seek(mod, seconds * 1000);
        return true;
    }

private:
    ModPlugFile* mod;
};

static const set<string> supported_ext{
    "mod", "xm",  "s3m", "oct", /*"okt", "okta", sucks here, use UADE */ "it",
    "ft",  "far", "ult", "669", "dmf",
    "mdl", "stm", "okt", "gdm", "mt2",
    "mtm", "j2b", "imf", "ptm", "ams"};

bool ModPlugin::canHandle(const std::string& name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* ModPlugin::fromFile(const std::string& fileName) {
    utils::File file{fileName};
    auto data = file.readAll();
    return new ModPlayer{&data[0], data.size()};
};

} // namespace musix
