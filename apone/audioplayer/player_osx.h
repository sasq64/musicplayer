#ifndef AUDIOPLAYER_OSX_H
#define AUDIOPLAYER_OSX_H

#include <AudioToolbox/AudioToolbox.h>

class InternalPlayer {
public:

	InternalPlayer(int hz = 44100) : freq(hz), quit(false) {
		init();
	}
	void init() {
		int bufSize = 32768/4;
		OSStatus status;
		AudioStreamBasicDescription fmt = { 0 };

		fmt.mSampleRate = freq;
		fmt.mFormatID = kAudioFormatLinearPCM;
		fmt.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
		fmt.mFramesPerPacket = 1;
		fmt.mChannelsPerFrame = 2;
		fmt.mBytesPerPacket = fmt.mBytesPerFrame = 2 * fmt.mChannelsPerFrame;
		fmt.mBitsPerChannel = 16;

		status = AudioQueueNewOutput(&fmt, fill_audio, this, NULL, NULL, 0, &aQueue);

  		//if (status == kAudioFormatUnsupportedDataFormatError)
		
		for(int i=0; i<4; i++) {
			AudioQueueBuffer *buf;
			status = AudioQueueAllocateBuffer(aQueue, bufSize, &buf);
			buf->mAudioDataByteSize = bufSize;
			fill_audio(this, aQueue, buf);
		}

 		status = AudioQueueSetParameter (aQueue, kAudioQueueParam_Volume, 1.0);
     	status = AudioQueueStart(aQueue, NULL);

	}

    void play(std::function<void(int16_t*, int)> cb) { callback = cb; }

	void pause(bool on) {
		if(on)
			AudioQueuePause(aQueue);
		else
     		AudioQueueStart(aQueue, NULL);
	}

	void set_volume(int volume) {
		float v = (float)volume / 100.f;
		AudioQueueSetParameter(aQueue, kAudioQueueParam_Volume, v);
	}
		


	static void fill_audio(void *ptr, AudioQueueRef aQueue, AudioQueueBuffer *buf) {
		int count = buf->mAudioDataByteSize / 2;
		int16_t *target = static_cast<int16_t*>(buf->mAudioData);
		InternalPlayer *player = static_cast<InternalPlayer*>(ptr);
        if(player->callback)
            player->callback(target, count);

		OSStatus status = AudioQueueEnqueueBuffer(aQueue, buf, 0, NULL);
	}

	int get_delay() const { return 1; }


	~InternalPlayer() {
		AudioQueueDispose(aQueue, true);
	}

	void writeAudio(int16_t *samples, int sampleCount) {
	}

	std::function<void(int16_t *, int)> callback;
	bool quit;
	int freq;
	AudioQueueRef aQueue;
};

#endif // AUDIOPLAYER_OSX_H
