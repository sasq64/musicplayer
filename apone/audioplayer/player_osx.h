#ifndef AUDIOPLAYER_OSX_H
#define AUDIOPLAYER_OSX_H

#include <AudioToolbox/AudioToolbox.h>

class InternalPlayer
{
public:
    explicit InternalPlayer(int hz = 44100) : freq(hz) { init(); }
    void init()
    {
        int bufSize = 32768 / 4;
        OSStatus status = 0;
        AudioStreamBasicDescription fmt = {0};

        fmt.mSampleRate = freq;
        fmt.mFormatID = kAudioFormatLinearPCM;
        fmt.mFormatFlags =
            kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        fmt.mFramesPerPacket = 1;
        fmt.mChannelsPerFrame = 2;
        fmt.mBytesPerPacket = fmt.mBytesPerFrame = 2 * fmt.mChannelsPerFrame;
        fmt.mBitsPerChannel = 16;

        status = AudioQueueNewOutput(&fmt, fill_audio, this, nullptr, nullptr,
                                     0, &aQueue);

        if (status == kAudioFormatUnsupportedDataFormatError) {
            throw std::exception();
        }

        for (int i = 0; i < 4; i++) {
            AudioQueueBuffer* buf = nullptr;
            status = AudioQueueAllocateBuffer(aQueue, bufSize, &buf);
            buf->mAudioDataByteSize = bufSize;
            fill_audio(this, aQueue, buf);
        }

        status = AudioQueueSetParameter(aQueue, kAudioQueueParam_Volume, 1.0);
        status = AudioQueueStart(aQueue, nullptr);
    }

    void play(std::function<void(int16_t*, int)> _callback)
    {
        callback = _callback;
    }

    void pause(bool on)
    {
        if (on) {
            AudioQueuePause(aQueue);
        } else {
            AudioQueueStart(aQueue, nullptr);
        }
    }

    void set_volume(int volume)
    {
        AudioQueueSetParameter(aQueue, kAudioQueueParam_Volume,
                               static_cast<float>(volume) / 100.F);
    }

    static void fill_audio(void* ptr, AudioQueueRef aQueue,
                           AudioQueueBuffer* buf)
    {
        auto count = buf->mAudioDataByteSize / 2;
        auto* target = static_cast<int16_t*>(buf->mAudioData);
        auto* player = static_cast<InternalPlayer*>(ptr);
        if (player->callback) {
            player->callback(target, static_cast<int>(count));
        } else {
            memset(target, 0, count * 2);
        }

        OSStatus status = AudioQueueEnqueueBuffer(aQueue, buf, 0, nullptr);
    }

    int get_delay() const { return 1; }

    ~InternalPlayer() { AudioQueueDispose(aQueue, 1); }

    void writeAudio(int16_t* samples, int sampleCount) {}

    std::function<void(int16_t*, int)> callback;
    bool quit{false};
    int freq;
    AudioQueueRef aQueue{};
};

#endif // AUDIOPLAYER_OSX_H
