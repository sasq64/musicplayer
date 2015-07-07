
#include "MP3Plugin.h"
#include "../../chipplayer.h"

#include <coreutils/utils.h>
#include <coreutils/file.h>

#include <mpg123.h>
//#include <curl/curl.h>

#include <coreutils/thread.h>

#include <set>
#include <unordered_map>

#ifdef EMSCRIPTEN
void srandom(unsigned int _seed)  { srand(_seed); }
long int random() { return rand(); }
#endif

using namespace std;
using namespace utils;

namespace chipmachine {

class MP3Player : public ChipPlayer {
public:

	MP3Player() {
		int err = mpg123_init();
		mp3 = mpg123_new(NULL, &err);
		bytesPut = 0;
		streamDone = false;
		if(mpg123_open_feed(mp3) != MPG123_OK)
			throw player_exception("Could open MP3");
	}

	MP3Player(const std::string &fileName) {
		int err = mpg123_init();
		mp3 = mpg123_new(NULL, &err);

		if(mpg123_open(mp3, fileName.c_str()) != MPG123_OK)
			throw player_exception("Could open MP3");

		int encoding = 0;
		if(mpg123_getformat(mp3, &rate, &channels, &encoding) != MPG123_OK)
			throw player_exception("Could not get format");
		LOGD("%d %d %d", rate, channels, encoding);
		mpg123_format_none(mp3);

		//mpg123_scan(mp3);
		checkMeta();

		mpg123_format(mp3, 44100, channels, encoding);
		//buf_size = 32768;
		//buffer = new unsigned char [buf_size];
	}

	~MP3Player() override {
		//delete [] buffer;
		if(mp3) {
			mpg123_close(mp3);
			mpg123_delete(mp3);
		}
		mpg123_exit();
	}

	void checkMeta() {

		if(!gotLength) {
			length = mpg123_length(mp3);
			if(length > 0) {
				LOGV("L %d T %f S %d", length, mpg123_tpf(mp3), mpg123_spf(mp3));
				length = length / mpg123_spf(mp3) * mpg123_tpf(mp3);
				gotLength = true;
				LOGD("MP3 LENGTH %ds", length);
				setMeta("length", length);
			}
		}

		int meta = mpg123_meta_check(mp3);
		mpg123_id3v1 *v1;
		mpg123_id3v2 *v2;
		if((meta & MPG123_NEW_ID3) && mpg123_id3(mp3, &v1, &v2) == MPG123_OK) {

			LOGV("New metadata");

			if(v2 && v2->title) {

				string msg;
				for(int i=0; i<v2->comments; i++) {
					if(msg.length())
						msg = msg + " ";
					msg = msg + v2->comment_list[i].text.p;
				}

				setMeta("title", htmldecode(v2->title->p),
					"composer", v2->artist ? htmldecode(v2->artist->p) : "",
					"message", msg,
					"format", "MP3",
					"length", length,
					"channels", channels);
			} else
			if(v1) {
				setMeta("title", v1->title ? htmldecode(v1->title) : "",
					"composer", v1->artist ? htmldecode(v1->artist) : "",
					"message", v1->comment ? v1->comment : "",
					"format", "MP3",
					"length", length,
					"channels", channels);
			} else {
				setMeta(
					"format", "MP3",
					"length", length,
					"channels", channels);
			}
		}
		if(meta)
			mpg123_meta_free(mp3);
	}

	virtual void putStream(const uint8_t *source, int size) {
		lock_guard<mutex> {m};
		if(!source) {
			if(size <= 0)
				streamDone = true;
			else
				mpg123_set_filesize(mp3, size);
			return;
		}

		mpg123_feed(mp3, source, size);
		bytesPut += size;
		int bytesRead = mpg123_framepos(mp3);

		int inBuffer = bytesPut - bytesRead;
		LOGD("IN BUFFER %d", inBuffer);

		//if(inBuffer > 100000) {
		//	utils::sleepms(750);
		//}

		checkMeta();
	}

	virtual int getSamples(int16_t *target, int noSamples) override {
		size_t done = 0;
		lock_guard<mutex> {m};
		if(bytesPut == 0)
			return 0;
		int err = mpg123_read(mp3, (unsigned char*)target, noSamples*2, &done);
		if(err == MPG123_NEW_FORMAT)
			return done/2;
		else
		if(err == MPG123_NEED_MORE) {
			if(streamDone)
				return -1;
		} else if(err < 0)
			return err;
		return done/2;
	}

	virtual bool seekTo(int song, int seconds) {
		return true;
	}

private:
	mpg123_handle *mp3;
	//size_t buf_size;
	//unsigned char *buffer;
	long rate;
	int channels;
	//thread httpThread;
	mutex m;
	bool gotLength = false;
	bool gotMeta = false;
	int length;
	int bytesPut;
	bool streamDone;
};

bool MP3Plugin::canHandle(const std::string &name) {
	auto ext = utils::path_extension(name);
	return ext == "mp3";
}

ChipPlayer *MP3Plugin::fromFile(const std::string &fileName) {
	return new MP3Player { fileName };
};

ChipPlayer *MP3Plugin::fromStream() {
	return new MP3Player();
}


}
