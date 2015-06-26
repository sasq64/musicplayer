#ifndef CHIP_PLAYER_H
#define CHIP_PLAYER_H

#include <coreutils/log.h>

#include <stdint.h>
#include <stdlib.h>
#include <string>
#include <cstdio>
#include <unordered_map>
#include <functional>
#include <vector>

namespace chipmachine {

class player_exception : public std::exception {
public:
	player_exception(const std::string &msg = "") : msg(msg) {}
	virtual const char *what() const throw() { return msg.c_str(); }
private:
	std::string msg;
};


class ChipPlayer {
public:
	typedef std::function<void(const std::vector<std::string> &meta, ChipPlayer*)> Callback;

	virtual ~ChipPlayer() {}
	virtual int getSamples(int16_t *target, int size) = 0;

	virtual void putStream(const uint8_t *source, int size) {};

	virtual std::string getMeta(const std::string &what) {
		return metaData[what];
	};

	int getMetaInt(const std::string &what) {
		const std::string &data = getMeta(what);
		int i = atoi(data.c_str());
		return i;
	};

	void setMeta() {
		for(auto cb : callbacks) {
			//LOGD("Calling callback for '%s'", meta);
			cb(changedMeta, this);
		}
		changedMeta.clear();
		LOGV("Meta Done");
	}

	template <typename... A> void setMeta(const std::string &what, int value, const A& ...args) {
		metaData[what] = std::to_string(value);
		LOGV("Meta %s=%s", what, metaData[what]);
		changedMeta.push_back(what);
		setMeta(args...);
	}

	template <typename... A> void setMeta(const std::string &what, const std::string &value, const A& ...args) {
		metaData[what] = value;
		LOGV("Meta %s=%s", what, metaData[what]);
		changedMeta.push_back(what);
		setMeta(args...);
	}

	template <typename... A> void setMeta(const std::string &what, const char *value, const A& ...args) {
		metaData[what] = std::string(value);
		LOGV("Meta %s=%s", what, metaData[what]);
		changedMeta.push_back(what);
		setMeta(args...);
	}

	virtual bool seekTo(int song, int seconds = -1) { printf("NOT IMPLEMENTED\n"); return false; }

	void onMeta(Callback callback) {
		//LOGD("Setting callback in %p", this);
		callbacks.push_back(callback);
		std::vector<std::string> meta;
		for(auto &md : metaData) {
			//LOGD("Calling callback for '%s'", md.first);
			meta.push_back(md.first);
		}
		callback(meta, this);
	}

protected:

	std::unordered_map<std::string, std::string> metaData;
	std::vector<Callback> callbacks;
	std::vector<std::string> changedMeta;

};

}

#endif // CHIP_PLAYER_H