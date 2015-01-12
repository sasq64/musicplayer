#pragma once

//#include <stdint.h>
#include <windows.h>

#include "Audio.h"

typedef void (*sndCallbackFunc)(short *stream, int len);

class AudioWinmm : public Audio {
public:
	AudioWinmm(void *userData, unsigned int sampleFrq_);
	virtual ~AudioWinmm();
	virtual void play();
	virtual void pause();
	virtual void stop();
	void reset();
	void setCallback(sndCallbackFunc);

protected:
	void write(HWAVEOUT hWaveOut, LPSTR data, int size);
	static sndCallbackFunc callback;
	static void CALLBACK sndCallbackFunc(HANDLE wout, UINT msg, DWORD user, DWORD dw1, DWORD dw2);
};
