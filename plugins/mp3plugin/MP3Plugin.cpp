
#include "MP3Plugin.h"
#include "../../chipplayer.h"

#include <coreutils/utils.h>
#include <coreutils/file.h>

#include <mpg123.h>
#include <curl/curl.h>

#include <mutex>
#include <thread>

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
	MP3Player(const std::string &fileName) {
		int err = mpg123_init();
		mp3 = mpg123_new(NULL, &err);

		if(startsWith(fileName, "http:")) {
			if(mpg123_open_feed(mp3) != MPG123_OK)
				throw player_exception("Could open MP3");
			httpThread = thread {&MP3Player::stream, this, fileName};

		} else {

			if(mpg123_open(mp3, fileName.c_str()) != MPG123_OK)
				throw player_exception("Could open MP3");

			int encoding = 0;
			if(mpg123_getformat(mp3, &rate, &channels, &encoding) != MPG123_OK)
				throw player_exception("Could not get format");
			LOGD("%d %d %d", rate, channels, encoding);
			mpg123_format_none(mp3);

			mpg123_scan(mp3);
			int meta = mpg123_meta_check(mp3);
			mpg123_id3v1 *v1;
			mpg123_id3v2 *v2;
			if(meta & MPG123_ID3 && mpg123_id3(mp3, &v1, &v2) == MPG123_OK) {

				int length = mpg123_length(mp3);
				if(length == MPG123_ERR)
					length = 0;
				else {
					 ;
					LOGD("L %d T %f S %d", length, mpg123_tpf(mp3), mpg123_spf(mp3));
					length = length / mpg123_spf(mp3) * mpg123_tpf(mp3);
				}

				if(v2 && v2->title) {

					setMeta("title", v2->title->p,
						"composer", v2->artist ? v2->artist->p : "",
						"message", v2->comment ? v2->comment->p : "",
						"format", "MP3",
						"length", length,
						"channels", channels);
				} else
				if(v1) {
					setMeta("title", v1->title ? v1->title : "",
						"composer", v1->artist ? v1->artist : "",
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

			mpg123_format(mp3, 44100, channels, encoding);
		}
		buf_size = 32768;
		buffer = new unsigned char [buf_size];

	}

	~MP3Player() override {
		delete [] buffer;
		if(mp3) {
			mpg123_close(mp3);
			mpg123_delete(mp3);
		}
		mpg123_exit();
	}

	void stream(const std::string &url) {

		auto u = urlencode(url, " #");

		LOGI("Downloading %s", url);
		CURL *curl;
		curl = curl_easy_init();
		curl_easy_setopt(curl, CURLOPT_URL, u.c_str());
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, this);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeFunc);
		//curl_easy_setopt(curl, CURLOPT_WRITEHEADER, this);
		//curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, headerFunc);
		int rc = curl_easy_perform(curl);

		LOGI("Curl returned %d", rc);
		curl_easy_cleanup(curl);
	}

	static size_t writeFunc(void *ptr, size_t size, size_t nmemb, void *userdata) {
		LOGD("Feeding %d bytes", size * nmemb);
		MP3Player *player = (MP3Player*)userdata;
		{
			lock_guard<mutex> {player->m};
			mpg123_feed(player->mp3, (unsigned char*)ptr, size*nmemb);
		}
		return size * nmemb;
	}

	virtual int getSamples(int16_t *target, int noSamples) override {
		size_t done;
		{
			lock_guard<mutex> {m};
			int err = mpg123_read(mp3, (unsigned char*)target, noSamples*2, &done);
		}
		return done/2;
		//return noSamples;
	}

	virtual bool seekTo(int song, int seconds) {
		return true;
	}

private:
	mpg123_handle *mp3;
	size_t buf_size;
	unsigned char *buffer;
	long rate;
	int channels;
	thread httpThread;
	mutex m;
};

bool MP3Plugin::canHandle(const std::string &name) {
	auto ext = utils::path_extension(name);
	return ext == "mp3";
}

ChipPlayer *MP3Plugin::fromFile(const std::string &fileName) {
	return new MP3Player { fileName };
};

}
