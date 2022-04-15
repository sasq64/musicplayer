#ifndef AUDIOPLAYER_WINDOWS_H
#define AUDIOPLAYER_WINDOWS_H

#include "audioplayer.h"

#include <vector>
#include <stdint.h>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <mmsystem.h>

#include <thread>
#include <mutex>
#include <atomic>

class InternalPlayer {
public:
	InternalPlayer(int hz = 44100) : quit(false) {
	}

    void play(std::function<void(int16_t*, int)> cb) { 
		callback = cb;
		playThread = std::thread { &InternalPlayer::run, this };
	}

	void run() {
		init();
		paused = false;
		std::vector<int16_t> buffer(4096);
		while(!quit) {
			if(!paused) {
				callback(&buffer[0], buffer.size());
				writeAudio(&buffer[0], buffer.size());
			}
		}

	}	

	~InternalPlayer();
	
	void init();
	void writeAudio(int16_t *samples, int sampleCount);

	void pause(bool on) {
		paused = on;
	}

	void set_volume(int level) {
		lock.lock();
		uint16_t v = (level * 0xffff) / 100;
		waveOutSetVolume(hWaveOut, v | (v<<16));
		lock.unlock();
	}

	int get_delay() const { return 2; }


private:

	std::thread playThread;

	std::function<void(int16_t *, int)> callback;


	std::mutex lock;
	std::atomic<int> blockCounter;
	std::atomic<int> blockPosition;

	HWAVEOUT hWaveOut;

	int bufSize;
	int bufCount;

	std::atomic<bool> quit;
	std::atomic<bool> paused;

	std::vector<std::vector<int16_t>> buffer;
	std::vector<WAVEHDR> header;

	static void CALLBACK waveOutProc(HWAVEOUT hWaveOut, UINT uMsg, DWORD_PTR dwInstance, DWORD_PTR dwParam1, DWORD_PTR dwParam2) {

		if(uMsg != WOM_DONE)
			return;

		InternalPlayer *ap = (InternalPlayer*)dwInstance;
		ap->lock.lock();
		ap->blockCounter--;
		ap->lock.unlock();
	}

};

//typedef AudioPlayerWindows AudioPlayerNative;

#endif // AUDIOPLAYER_WINDOWS_H
