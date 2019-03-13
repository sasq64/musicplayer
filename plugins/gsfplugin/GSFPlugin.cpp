

#include "GSFPlugin.h"

#include <psf/PSFFile.h>
#include <coreutils/utils.h>
#include <set>
#include <stdio.h>
#include <stdlib.h>
#include <unordered_map>

#include <types.h>

extern "C" {
#include "VBA/psftag.h"
#include "gsf.h"
}

#include <coreutils/fifo.h>

extern "C" {
int defvolume = 1000;
int relvolume = 1000;
int TrackLength = 0;
int FadeLength = 0;
int IgnoreTrackLength, DefaultLength = 150000;
int playforever = 1;
int fileoutput = 0;
int TrailingSilence = 1000;
int DetectSilence = 0, silencedetected = 0, silencelength = 5;

int cpupercent = 0, sndSamplesPerSec, sndNumChannels;
int sndBitsPerSample = 16;

int deflen = 120, deffade = 4;

int decode_pos_ms; // current decoding position, in milliseconds

extern unsigned short soundFinalWave[2304];

extern int soundBufferLen;

}
/*
extern char soundEcho;
extern char soundLowPass;
extern char soundReverse;
extern char soundQuality;*/

static utils::Fifo<int16_t>* gsfFifo = nullptr;

extern "C" void end_of_track() {
    // LOGD("END OF TRACK");
}

extern "C" void writeSound(void) {
    // int tmp;
    gsfFifo->put((short*)soundFinalWave, soundBufferLen / 2);
    decode_pos_ms +=
        (soundBufferLen / (2 * sndNumChannels) * 1000) / sndSamplesPerSec;
}


namespace musix {

class GSFPlayer : public ChipPlayer {
public:
    GSFPlayer(const std::string& fileName) : fifo(512 * 1024), psf{fileName} {

        decode_pos_ms = 0;
        TrailingSilence = 1000;
        IgnoreTrackLength = 1;
        DetectSilence = 0;
        silencedetected = 0;
        playforever = 1;

        gsfFifo = &fifo;

        if(psf.valid()) {
            auto& tags = psf.tags();

            int seconds = psf.songLength();

            setMeta("composer", tags["artist"], "sub_title", tags["title"],
                    "game", tags["game"], "format", "Gameboy Advance", "length",
                    seconds);
        }

        LOGD("GSF:%s", fileName.c_str());

        int r = GSFRun((char*)fileName.c_str());
    }

    ~GSFPlayer() { GSFClose(); }

    virtual int getSamples(int16_t* target, int noSamples) override {
        int lastTL = TrackLength;
        while(fifo.filled() < noSamples * 2) {
            EmulationLoop();
        }

        if(decode_pos_ms > TrackLength && !playforever)
            return -1;

        if(fifo.filled() == 0)
            return 0;

        int len = fifo.get(target, noSamples);
        return len;
    }

private:
    utils::Fifo<int16_t> fifo;
    PSFFile psf;
};

static const std::set<std::string> supported_ext{"gsf", "minigsf"};

bool GSFPlugin::canHandle(const std::string& name) {
    auto ext = utils::path_extension(name);
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* GSFPlugin::fromFile(const std::string& fileName) {
    return new GSFPlayer{fileName};
};

} // namespace musix
