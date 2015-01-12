#ifndef DS_FIFO_H
#define DS_FIFO_H

#include <cstdlib>
#include <cstring>
#include <cstdint>

#include <coreutils/log.h>

class Fifo {

public:
	Fifo(int size) {
		this->size = size;
		volume = 1.0;
		buffer = NULL;
		if(size > 0) {
			buffer = (uint8_t *)malloc(size);
		}
		bufPtr = buffer;
		lastSoundPos = position = 0;
	}
	~Fifo() {
		if(buffer)
			free(buffer);
	}
	void putBytes(uint8_t *src, int bytelen) {
		if(src)
			memcpy(bufPtr, src, bytelen);
		bufPtr += bytelen;
	}
	void putShorts(short *src, int shortlen) {
		putBytes((uint8_t*)src, shortlen*2);
	}
	int getBytes(uint8_t *dest, int bytelen) {
		int filled = bufPtr - buffer;
		if(bytelen > filled)
			bytelen = filled;

		memcpy(dest, buffer, bytelen);
		if(filled > bytelen)
			memmove(buffer, &buffer[bytelen], filled - bytelen);
		bufPtr = &buffer[filled - bytelen];

		return bytelen;
	}

	int getShorts(short *dest, int shortlen) {
		return getBytes((uint8_t*)dest, shortlen*2) / 2;
	}

	void processShorts(short *src, int shortlen) {
		processBytes((uint8_t*)src, shortlen*2);
	}

	void processBytes(uint8_t *s, int bytelen) {

		uint8_t *src = s;
		if(src == nullptr)
			src = bufPtr;

		putBytes(s, bytelen);

		int soundPos = -1;
		short *samples = (short*)src;

		if(volume != 1.0) {
			for(int i=0; i<bytelen/2; i++) {
				samples[i] = (samples[i] * volume);
			}
		}
		for(int i=0; i<bytelen/2; i++) {
			short s = samples[i];
			if(s > 16 || s < -16)
				soundPos = i;
		}
		if(soundPos >= 0)
			lastSoundPos = position + soundPos;

		position += (bytelen/2);
	}


	void clear() {
		volume = 1.0;
		bufPtr = buffer;
		lastSoundPos = position = 0;

	}

	int filled() { return bufPtr - buffer; }

	int left() { return size - (bufPtr - buffer); }

	int getSilence() { return position - lastSoundPos; }
	void setVolume(float v) { volume = v; }

	uint8_t *ptr() { return bufPtr; }

	float getVolume() { return volume; }

private:
	float volume;

	//short startLoop[44100*10];
	//int loopPos;
	int size;
	int lastSoundPos;
	int position;
	uint8_t *buffer;
	uint8_t *bufPtr;

};

#endif
