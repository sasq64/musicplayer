#ifndef PLAYER_SL_H
#define PLAYER_SL_H

#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>

#include <functional>
#include <stdexcept>
#include <string>
#include <vector>

class sl_exception : public std::exception {
public:
	sl_exception(const std::string &msg) : msg(msg) {}
	virtual const char *what() const throw() { return msg.c_str(); }
private:
	std::string msg;
};

class InternalPlayer {
public:
	InternalPlayer(int hz = 44100) : quit(false), paused(false) {
		init();
	}

	InternalPlayer(std::function<void(int16_t *, int)> cb, int hz = 44100) : callback(cb), quit(false), paused(false) {
		init();
	}

	void init();

	void pause(bool on) {
		paused = on;
		if(!paused) {
			callback(&buffer[0], 32768);
			(*bqPlayerBufferQueue)->Enqueue(bqPlayerBufferQueue, &buffer[0], 32768*2);
		}
	}
	int get_delay() const {
		return 1;
	}
	void set_volume(int volume) {
	}
private:

	static void bqPlayerCallback(SLAndroidSimpleBufferQueueItf bq, void *context);

	std::function<void(int16_t *, int)> callback;
	bool quit;
	bool paused;

	std::vector<int16_t> buffer;

	SLObjectItf engineObject;
	SLEngineItf engineEngine;
	SLObjectItf outputMixObject;

	SLObjectItf bqPlayerObject;
	SLPlayItf bqPlayerPlay;
	SLAndroidSimpleBufferQueueItf bqPlayerBufferQueue;
	//SLEffectSendItf bqPlayerEffectSend;
};

#endif // PLAYER_SL_H
