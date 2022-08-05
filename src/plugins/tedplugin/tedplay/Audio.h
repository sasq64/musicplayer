#pragma once

#include <cstdio>

typedef void (*callbackFunc)(unsigned char *stream, int len);

// WAV file header structure
// should be 1-byte aligned
#pragma pack(1)
struct WAVHEADER {
    char riff[4];
    unsigned int rLen;
    char WAVEfmt[8];
    unsigned int fLen; /* 0x1020 */;
    unsigned short wFormatTag; /* 0x0001 */
    unsigned short nChannels; /* 0x0001 */
    unsigned int nSamplesPerSec;
    unsigned int nAvgBytesPerSec; // nSamplesPerSec*nChannels*(nBitsPerSample%8)
    unsigned short nBlockAlign; /* 0x0001 */
    unsigned short nBitsPerSample; /* 0x0008 */    
    char datastr[4];
    unsigned int cbSize;
};
#pragma pack()

class Audio {
public:
	Audio(unsigned int sampleFrq_) : bufferLength(4096), sampleFrq(sampleFrq_) { // 2048
		recording = false;
		wavFileHandle = 0;
	}
	virtual ~Audio() {};
	virtual void play() = 0;
	virtual void pause() = 0;
	virtual void stop() = 0;
	virtual void sleep(unsigned int msec) = 0;
	virtual void flush() {
		unsigned int msec = (unsigned int)(1000.f * double(bufferLength)/double(sampleFrq) + 1);
		sleep(msec);
	}
	virtual void lock() = 0;
	virtual void unlock() = 0;
	virtual void setSampleRate(unsigned int newSampleRate) {
		sampleFrq = newSampleRate;
	}
	unsigned int getLatency() {
		unsigned int msec = (unsigned int)(1000.f * double(bufferLength)/double(sampleFrq) + 1);
		return msec;
	}
	unsigned int getSampleRate() { return sampleFrq; }
	bool isPaused() { return paused; };
	virtual bool createWav(const char *fileName);
	virtual void closeWav();
	static bool dumpWavData(FILE *fp, unsigned char *buffer, unsigned int length);
	static short getLastSample() { return lastSample; };

protected:
	unsigned int bufferLength;
	static bool paused;
	static callbackFunc callback;
	static void audioCallback(void *userData, unsigned char *stream, int len);
	static short *ringBuffer;
	static size_t ringBufferSize;
	static size_t ringBufferIndex;
	static bool recording;
	static FILE *wavFileHandle;
	static size_t wavDataLength;
	static short lastSample;
private:
	unsigned int sampleFrq;
};
