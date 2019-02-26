#pragma once

#include "log.h"
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <chrono>
using namespace std::chrono_literals;

namespace utils {

template <typename T> class Fifo {

public:
	Fifo(int size = 0) {
		bufSize = size;
		buffer = nullptr;
		if(size > 0) {
			buffer = new T [size];
		}
		bufPtr.store(buffer.load());
		wantToWrite = 0;
	}

    void resize(int size) {
		bufSize = size;
        if(buffer)
            delete[] buffer;
        buffer = new T [size];
		bufPtr.store(buffer.load());
		wantToWrite = 0;
    }

	~Fifo() {
		// Wait for writers to finish
		quitting = true;
		while(wantToWrite > 0)
			cv.notify_all();
		if(buffer) {
			T* b = buffer.load();
			delete [] b;
		}
	}

	void quit() {
		quitting = true;
		while(wantToWrite > 0)
			cv.notify_all();
	}

	Fifo& operator=(Fifo&) = delete;

	Fifo(const Fifo& other) {
		bufSize.store(other.bufSize);
		buffer = nullptr;
		if(bufSize > 0) {
			buffer = new T [bufSize];
            memcpy(buffer, other.buffer, bufSize * sizeof(T));
		}

		bufPtr.store(buffer.load());
		wantToWrite = 0;
    };

	void clear() {
		{
			std::unique_lock<std::mutex> lock(m);
			bufPtr.store(buffer);
		}
		cv.notify_all();
	}

	void put(const T *source, int count) {
		if(quitting)
			return;

		std::unique_lock<std::mutex> lock(m);
		while(left() < count && !quitting) {
			if(wantToWrite == 0)
				wantToWrite = count;
			cv.wait_for(lock, 100ms, [=] {
				return left() >= count || quitting;
			});
		}
		wantToWrite = 0;
		if(quitting)
			return;

		if(source)
			memcpy(bufPtr, source, sizeof(T) * count);
		bufPtr += count;
	}

    void put(T a, T b) {
        T t[2] = { a, b };
        put(t, 2);
    }

    template<typename FN> void put(int count, const FN& f) {
		if(quitting)
			return;

		std::unique_lock<std::mutex> lock(m);
		while(left() < count && !quitting) {
			if(wantToWrite == 0)
				wantToWrite = count;
			cv.wait_for(lock, 100ms, [=] {
				return left() >= count || quitting;
			});
		}
		wantToWrite = 0;
		if(quitting)
			return;

        f(bufPtr);
		bufPtr += count;
    }

	int get(T *target, int count) {
		if(quitting)
			return -1;

		{
			std::unique_lock<std::mutex> lock(m);
			int f = filled();
			if(count > f)
				count = f;

			memcpy(target, buffer, count * sizeof(T));
			if(f > count)
				memmove(buffer, &buffer[count], (f - count) * sizeof(T));
			bufPtr = &buffer[f - count];
		}

		if(left() >= wantToWrite)
			cv.notify_all();

		return count;
	}

	template<typename FN> int get(int count, const FN& fn) {
		if(quitting)
			return -1;

		{
			std::unique_lock<std::mutex> lock(m);
			int f = filled();
			if(count > f)
				count = f;

            fn(buffer);
			if(f > count)
				memmove(buffer, &buffer[count], (f - count) * sizeof(T));
			bufPtr = &buffer[f - count];
		}

		if(left() >= wantToWrite)
			cv.notify_all();

		return count;
	}

	int filled() const {
	   	return bufPtr - buffer; 
	}
	int left() { 
		return bufSize - (bufPtr - buffer); 
	}
	int size() {
	   	return bufSize; 
	}
	T *ptr() { return bufPtr; }

protected:

	std::mutex m;
	std::condition_variable cv;

	std::atomic<int> wantToWrite;
	std::atomic<int> bufSize;
	std::atomic<int> position;
	std::atomic<T*> buffer;
	std::atomic<T*> bufPtr;
	std::atomic<bool> quitting{false};

};


template <typename T> class AudioFifo : public Fifo<T> {

public:
	explicit AudioFifo(int size = 0) : Fifo<T>(size) {
		volume = 1.0;
		lastSoundPos = position = 0;
	}

	void process(T *samples, int count) {

		int soundPos = -1;

		for(int i=0; i<count; i++) {
			short s = samples[i];
			if(s > 16 || s < -16)
				soundPos = i;
		}

		if(volume != 1.0) {
			for(int i=0; i<count; i++) {
				samples[i] = (samples[i] * volume);
			}
		}

		if(soundPos >= 0)
			lastSoundPos = position + soundPos;

		position += count;
	}

	void put(T *target, int count) {
		Fifo<T>::put(target, count);
		process(Fifo<T>::bufPtr - count, count);
	}

	void clear() {
		Fifo<T>::clear();
		volume = 1.0;
		lastSoundPos = position = 0;
	}

	int getSilence() { return position - lastSoundPos; }
	void setVolume(float v) { volume = v; }
	float getVolume() { return volume; }

private:
	float volume;

	int lastSoundPos;
	int position;

};

} // namespace utils

