#include <SDL.h>
#include <iostream>
#include "AudioSDL.h"
#include "Tedmem.h"

#ifndef WIN32
#pragma comment(lib, "SDL.lib")

bool AudioSDL::hasSDL()
{
	return true;
}

#else

#define LOADFUNC(NAME) NAME = GetProcAddress(SDL_DLL, "NAME");
#define EXTERN __declspec(dllimport)

typedef int EXTERN (*_SDL_OpenAudio)(HWND hWnd, DWORD dwFlags);
typedef _SDL_PauseAudio EXTERN (*_GXGetDisplayProperties)();
typedef int EXTERN *(*_SDL_LockAudio)();
typedef void EXTERN (*_SDL_UnlockAudio)();
typedef void EXTERN (*_SDL_CloseAudio)();

static _SDL_OpenAudio	SDL_OpenAudio;
static _SDL_PauseAudio	SDL_PauseAudio;
static _SDL_LockAudio	SDL_LockAudio;
static _SDL_UnlockAudio SDL_UnlockAudio;
static _SDL_Delay		SDL_Delay;
static _SDL_CloseAudio	SDL_CloseAudio;

bool AudioSDL::hasSDL()
{
	HINSTANCE sdlDll = LoadLibrary("SDL.DLL");
	return sdlDll != 0;
}

#endif

void AudioSDL::setCallback(callbackFunc callback_)
{
	SDL_LockAudio();
	callback = callback_;
	SDL_UnlockAudio();
}

void AudioSDL::setSampleRate(unsigned int newSampleRate)
{
	if (audiohwspec) {
		SDL_PauseAudio(1);
		unsigned int fadeoutTime = 1000 * bufferLength / audiohwspec->samples;
		SDL_Delay(fadeoutTime);
		SDL_CloseAudio();

		SDL_AudioSpec *obtained = new SDL_AudioSpec;
		audiohwspec->samples = newSampleRate;
		try {
			SDL_OpenAudio(audiohwspec, obtained);
			if (obtained) {
				SDL_AudioSpec *temp = audiohwspec;
				audiohwspec = obtained;
				delete temp;
			}
			SDL_PauseAudio(0);
		} catch (char *txt) {
			std::cerr << "Exception occurred: " << txt << std::endl;
		}
	} else {
	}
	Audio::setSampleRate(newSampleRate);
}

AudioSDL::AudioSDL(void *userData, unsigned int sampleFrq_ = 48000, 
				   unsigned int bufDurInMsec = 40) : Audio(sampleFrq_), audiohwspec(0)
{
	if (SDL_Init(SDL_INIT_AUDIO) < 0) { //  SDL_INIT_AUDIO|
		std::cerr << "Unable to init SDL: " << SDL_GetError() << std::endl;
		exit(1);
	}
	atexit(SDL_Quit);

	SDL_AudioSpec *desired, *obtained = NULL;

	try {
		desired = new SDL_AudioSpec;
		obtained = new SDL_AudioSpec;
	} catch(char *txt) {
		std::cerr << "Exception occurred: " << txt << std::endl;
	}

	unsigned int fragsPerSec = 1000 / bufDurInMsec;
	unsigned int bufSize1kbChunk = (sampleFrq_ / fragsPerSec / 1024) * 1024;
	if (!bufSize1kbChunk) bufSize1kbChunk = 512;
	bufferLength = bufSize1kbChunk;

	desired->freq		= sampleFrq_;
	desired->format		= AUDIO_S16;
	desired->channels	= 1;
	desired->samples	= bufferLength;
	desired->callback	= audioCallback;
	desired->userdata	= userData;
	desired->size		= desired->channels * desired->samples * sizeof(Uint8);
	desired->silence	= 0x00;

	unsigned int bfSize = TED_SOUND_CLOCK / fragsPerSec; //(bufferLength * TED_SOUND_CLOCK + sampleFrq_ / 2) / sampleFrq_;
	// double length ring buffer, dividable by 8
	ringBufferSize = (bfSize / 8 + 1) * 16;
	ringBuffer = new short[ringBufferSize];
	// trigger initial buffer fill
	ringBufferIndex = ringBufferSize-1;

	if (SDL_OpenAudio(desired, obtained)) {
		fprintf(stderr,"SDL_OpenAudio failed!\n");
		return;
	} else {
		char drvnamebuf[16];
		fprintf(stderr,"SDL_OpenAudio success!\n");
		SDL_AudioDriverName( drvnamebuf, 16);
		fprintf(stderr, "Using audio driver : %s\n", drvnamebuf);		
		if ( obtained == NULL ) {
			fprintf(stderr, "Great! We have our desired audio format!\n");
			audiohwspec = desired;
			delete obtained;
		} else {
			//fprintf(stderr, "Oops! Failed to get desired audio format!\n");
			audiohwspec = obtained;
			delete desired;
		}
	}
	paused = true;
}

void AudioSDL::play()
{
	SDL_PauseAudio(0);
	paused = false;
}

void AudioSDL::pause()
{
	SDL_PauseAudio(1);
	paused = true;
}

void AudioSDL::stop()
{
	SDL_PauseAudio(1);
	paused = true;
}

void AudioSDL::sleep(unsigned int msec)
{
	SDL_Delay(msec);
}

void AudioSDL::lock()
{
	SDL_LockAudio();
}
void AudioSDL::unlock()
{
	SDL_UnlockAudio();
}

AudioSDL::~AudioSDL()
{
    SDL_PauseAudio(1);
    SDL_Delay(20);
	SDL_CloseAudio();
	SDL_Quit();
	if (audiohwspec)
		delete audiohwspec;
	if (ringBuffer)
		delete [] ringBuffer;
}