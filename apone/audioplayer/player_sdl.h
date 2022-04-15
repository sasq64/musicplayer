#ifndef AUDIOPLAYER_SDL_H
#define AUDIOPLAYER_SDL_H

#include "audioplayer.h"

#include <SDL.h>


class InternalPlayer {
public:
	InternalPlayer(int hz = 44100) : quit(false) {
		init();
	}

	InternalPlayer(std::function<void(int16_t *, int)> cb, int hz = 44100) : callback(cb), quit(false) {
		init();
	}
	void init() {
		//LOGD("Opening audio");
		uint16_t bufSize = 32768/16;
		SDL_AudioSpec wanted = { 44100, AUDIO_S16, 2, 0, bufSize, 0, 0, fill_audio, this };
	    if(SDL_OpenAudio(&wanted, NULL) < 0 ) {
	        //fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
	        throw audio_exception("Could not open audio");
	    } else
			SDL_PauseAudio(0);
		//callback(fifo.ptr<int16_t>(), fifo.size()/2);
		//fifo.putBytes(nullptr, fifo.size());
	}

	void pause(bool on) {
		SDL_PauseAudio(on ? 1 : 0);
	}

	static void fill_audio(void *udata, Uint8 *stream, int len) {
		auto *iplayer = (InternalPlayer*)udata;
		iplayer->callback((int16_t*)stream, len/2);
	}

	int get_delay() const { return 1; }


	~InternalPlayer() {
		SDL_CloseAudio();
	}

	void writeAudio(int16_t *samples, int sampleCount) {
	}

	std::function<void(int16_t *, int)> callback;
	bool quit;
	//Fifo fifo;

};

#endif // AUDIOPLAYER_SDL_H
