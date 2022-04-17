
#include "TEDPlugin.h"
#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include "tedplay/Audio.h"
#include "tedplay/Tedmem.h"
#include "tedplay/tedplay.h"
#include <set>

namespace musix {

class PluginAudio : public Audio
{
public:
    PluginAudio() : Audio(44100)
    {

        int bufDurInMsec = 100;

        paused = false;
        recording = false;

        unsigned int fragsPerSec = 1000 / bufDurInMsec;
        unsigned int bufSize1kbChunk = (44100 / fragsPerSec / 1024) * 1024;
        if (bufSize1kbChunk == 0) { bufSize1kbChunk = 512; }
        bufferLength = bufSize1kbChunk;

        unsigned int bfSize =
            TED_SOUND_CLOCK / fragsPerSec; //(bufferLength * TED_SOUND_CLOCK +
                                           // sampleFrq_ / 2) / sampleFrq_;
        // double length ring buffer, dividable by 8
        ringBufferSize = (bfSize / 8 + 1) * 16;
        ringBuffer = new short[ringBufferSize];
        // trigger initial buffer fill
        ringBufferIndex = ringBufferSize - 1;
    }

    void play() override {}
    void pause() override {}
    void stop() override {}
    void sleep(unsigned int msec) override
    {
        static unsigned char buffer[32768];
        int bytes = 44100 * msec / 1000;
        LOGD("SLEEP %d msec = %d bytes", msec, bytes);
        if (bytes > sizeof(buffer)) bytes = sizeof(buffer);
        audioCallback((void*)ted, buffer, bytes);
    }

    void flush() override
    {
        // unsigned int msec = (unsigned int)(1000.f *
        // double(bufferLength)/double(sampleFrq) + 1); sleep(msec);
    }
    void lock() override {}
    void unlock() override {}

    void getSamples(int16_t* target, int noSamples) const
    {
        audioCallback((void*)ted, reinterpret_cast<unsigned char*>(target),
                      noSamples);
        for (int i = (noSamples - 1) / 2; i >= 0; i--) {
            target[i * 2] = target[i * 2 + 1] = target[i];
        }
    }

    TED* ted;
};

class TEDPlayer : public ChipPlayer
{
public:
    explicit TEDPlayer(const std::string& fileName) : audio(new PluginAudio())
    {

        LOGD("Trying to play TED music");

        audio->ted = machineInit(44100, 24);
        tedplayMain(fileName.c_str(), audio);

        // audio->sleep(300);
        // audio->ted->putKey(1);

        setMeta("songs", 10);
        // "game", track0->game,
        // "composer", track0->author,
        // "copyright", track0->copyright,
        // "length", track0->length > 0 ? track0->length / 1000 : 0,
        // "sub_title", track0->song,
        // "format", track0->system,
        // "songs", gme_track_count(emu)
        //);
    }
    ~TEDPlayer() override { tedplayClose(); }

    int getSamples(int16_t* target, int noSamples) override
    {
        audio->getSamples(target, noSamples);
        if (!haveSound) {
            int s = 0;
            for (int i = 0; (s == 0) && i < noSamples; i += 8) {
                s += target[i];
            }
            if (s == 0) {
                counter++;
                if (counter % 3 == 0) { audio->ted->putKey(counter / 3 - 1); }
            } else {
                haveSound = true;
            }
        }
        return noSamples;
    }

    bool seekTo(int song, int /*seconds*/) override
    {
        LOGD("Seek {}", song);
        audio->ted->putKey(song + 1);
        return true;
    }

private:
    PluginAudio* audio;
    TED* ted = nullptr;
    bool haveSound = false;
    int counter = 0;
};

bool TEDPlugin::canHandle(const std::string& name)
{
    return utils::path_extension(name) == "prg";
}

ChipPlayer* TEDPlugin::fromFile(const std::string& name)
{
    return new TEDPlayer{name};
};

} // namespace musix
