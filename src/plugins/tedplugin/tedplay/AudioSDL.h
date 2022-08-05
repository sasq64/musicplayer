#pragma once

#include "Audio.h"

class AudioSDL : public Audio {
public:
	AudioSDL(void *userData, unsigned int sampleFrq_, unsigned int bufDurInMsec);
	virtual ~AudioSDL();
	virtual void play();
	virtual void pause();
	virtual void stop();
	virtual void sleep(unsigned int msec);
	virtual void lock();
	virtual void unlock();
	virtual void setSampleRate(unsigned int newSampleRate);
	static void setCallback(callbackFunc);
	static bool hasSDL();
protected:
	SDL_AudioSpec *audiohwspec;
};
