
#include "MP3Plugin.h"
#include "../../chipplayer.h"

#include <coreutils/fifo.h>
#include <coreutils/file.h>
#include <coreutils/split.h>
#include <coreutils/utils.h>

#include <mpg123.h>
//#include <curl/curl.h>

#include <coreutils/thread.h>

#include <set>
#include <unordered_map>

#ifdef EMSCRIPTEN
void srandom(unsigned int _seed)
{
    srand(_seed);
}
long int random()
{
    return rand();
}
#endif

using namespace std;
using namespace utils;

namespace musix {

class MP3Player : public ChipPlayer
{
public:
    MP3Player(std::shared_ptr<utils::Fifo<uint8_t>> fifo) : fifo(fifo)
    {
        int err = mpg123_init();
        mp3 = mpg123_new(NULL, &err);
        mpg123_param(mp3, MPG123_ADD_FLAGS, MPG123_QUIET, 0);
        bytesPut = 0;
        streamDone = false;
        totalSize = 0;
    }

    bool setParameter(const std::string& param, int32_t v) override
    {
        if (!opened) {
            if (mpg123_open_feed(mp3) != MPG123_OK)
                throw player_exception("Could open MP3");
            opened = true;
        }
        if (param == "icy-interval") {
            LOGD("ICY INTERVAL %d", v);
            // mpg123_param(mp3, MPG123_ICY_INTERVAL, v, 0);
            metaInterval = v;
            return true;
        }
        if (param == "size") {
            mpg123_set_filesize(mp3, v);
            fileSize = v;
            return true;
        }
        return false;
    }

    MP3Player(const std::string& fileName)
    {
        int err = mpg123_init();
        mp3 = mpg123_new(NULL, &err);
        mpg123_param(mp3, MPG123_ADD_FLAGS, MPG123_QUIET, 0);

        if (mpg123_open(mp3, fileName.c_str()) != MPG123_OK)
            throw player_exception("Could open MP3");
        bytesPut = 1;
        int encoding = 0;
        if (mpg123_getformat(mp3, &rate, &channels, &encoding) != MPG123_OK)
            throw player_exception("Could not get format");
        LOGD("%d %d %d", rate, channels, encoding);
        mpg123_format_none(mp3);

        // mpg123_scan(mp3);
        checkMeta();

        mpg123_format(mp3, 44100, channels, encoding);
        // buf_size = 32768;
        // buffer = new unsigned char [buf_size];
    }

    ~MP3Player() override
    {
        // delete [] buffer;
        LOGD("Destroying MP3Player");
        if (mp3) {
            mpg123_close(mp3);
            mpg123_delete(mp3);
        }
        mpg123_exit();
    }

    void checkMeta()
    {

        if (!gotLength && (bytesPut == -1 || fileSize > 0)) {
            length = mpg123_length(mp3);
            if (length > 0) {
                LOGD("L %d T %f S %d", length, mpg123_tpf(mp3),
                     mpg123_spf(mp3));
                length = length / mpg123_spf(mp3) * mpg123_tpf(mp3);
                gotLength = true;
                LOGD("MP3 LENGTH %ds", length);
                setMeta("length", length);
            }
        }

        int meta = mpg123_meta_check(mp3);
        mpg123_id3v1* v1;
        mpg123_id3v2* v2;
        if (meta & MPG123_ICY) {
            char* icydata;
            if (mpg123_icy(mp3, &icydata) == MPG123_OK) {
                LOGD("ICY:%s", icydata);
            }
        }
        if ((meta & MPG123_NEW_ID3) && mpg123_id3(mp3, &v1, &v2) == MPG123_OK) {

            LOGV("New metadata");

            if (v2 && v2->title) {

                string msg;
                for (int i = 0; i < (int)v2->comments; i++) {
                    if (msg.length())
                        msg = msg + " ";
                    msg = msg + v2->comment_list[i].text.p;
                }

                setMeta("title", htmldecode(v2->title->p), "composer",
                        v2->artist ? htmldecode(v2->artist->p) : "", "message",
                        msg, "format", "MP3", "length", length, "channels",
                        channels);
            } else if (v1) {
                setMeta("title", htmldecode(v1->title), "composer",
                        htmldecode(v1->artist), "message", v1->comment,
                        "format", "MP3", "length", length, "channels",
                        channels);
            } else {
                setMeta("format", "MP3", "length", length, "channels",
                        channels);
            }
        }
        if (meta)
            mpg123_meta_free(mp3);
    }

    std::shared_ptr<utils::Fifo<uint8_t>> fifo;

    void putStream(const uint8_t* source, int size)
    {
        long buffered = 0;
        {
            if (!opened) {
                if (mpg123_open_feed(mp3) != MPG123_OK)
                    throw player_exception("Could not open MP3");
                opened = true;
            }
            if (!source) {
                if (size <= 0)
                    streamDone = true;
                // else
                //	mpg123_set_filesize(mp3, size);
                return;
            }

            totalSize += size;
            do {

                if (metaInterval > 0 && metaCounter + size > metaInterval) {
                    // This batch includes start of meta block
                    int pos = metaInterval - metaCounter;
                    metaSize = source[pos] * 16;

                    LOGV("METASIZE %d at offset %d", metaSize, pos);

                    if (pos > 0)
                        mpg123_feed(mp3, source, pos);
                    source += (pos + 1);
                    size -= (pos + 1);
                    bytesPut += (pos + 1);
                    metaCounter = 0;
                    icyPtr = icyData;
                }

                if (metaSize > 0) {
                    int metaBytes = size > metaSize ? metaSize : size;
                    LOGD("Metabytes %d", metaBytes);

                    memcpy(icyPtr, source, metaBytes);
                    icyPtr += metaBytes;
                    *icyPtr = 0;

                    size -= metaBytes;
                    source += metaBytes;
                    metaSize -= metaBytes;

                    if (metaSize <= 0) {
                        LOGD("META: %s", icyData);
                        icyPtr = icyData;

                        auto parts = split(string(icyData), ";");
                        for (const auto& p : parts) {
                            std::vector<std::string> data = split(p, "=", 2);
                            if (data.size() == 2) {
                                if (data[0] == "StreamTitle") {
                                    auto title =
                                        data[1].substr(1, data[1].length() - 2);
                                    setMeta("sub_title", utf8_encode(title));
                                }
                            }
                        }
                    }
                }
            } while (metaInterval > 0 && metaCounter + size > metaInterval);

            if (size > 0) {
                mpg123_feed(mp3, source, size);
                if (metaInterval > 0)
                    metaCounter += size;
            }

            bytesPut += size;
            int bytesRead = mpg123_framepos(mp3);

            int inBuffer = bytesPut - bytesRead;

            checkMeta();
        }
    }

    virtual int getSamples(int16_t* target, int noSamples) override
    {

        long buffered;
        mpg123_getstate(mp3, MPG123_BUFFERFILL, &buffered, nullptr);

        if (fifo && (buffered < 1024 * 128 || totalSeconds == 0)) {
            int sz = fifo->filled();

            if (sz > 0) {
                static uint8_t temp[8192];
                if (sz > 8192)
                    sz = 8192;
                // LOGD("Getting %d bytes from stream", sz);
                fifo->get(temp, sz);
                putStream(temp, sz);
            }
        }

        size_t done = 0;
        if (bytesPut == 0)
            return 0;
        int err =
            mpg123_read(mp3, (unsigned char*)target, noSamples * 2, &done);

        totalSeconds += ((double)done / (44100 * 4));
        // LOGD("BUFFERED %d SECONDS %d (done %d)", buffered, totalSeconds,
        // done);
        if (totalSeconds > 2) {
            auto r = (double)(totalSize - buffered) / totalSeconds;
            r = (r * 8) / 1000;
            if (bitRate == 0)
                bitRate = r;
            else
                bitRate = r * 0.25 + bitRate * 0.75;
            // LOGD("Bitrate %f %d kbit (%d) %d", r, bitRate, totalSize,
            // totalSeconds);
            setMeta("bitrate", (int)bitRate);
        }

        if (err != 0 && err != MPG123_NEED_MORE) {
            LOGD("MP3 Error %d", err);
        }

        if (err == MPG123_NEW_FORMAT)
            return done / 2;
        else if (err == MPG123_NEED_MORE) {
            if (streamDone)
                return -1;
        } else if (err < 0)
            return err;

        return done / 2;
    }

    virtual bool seekTo(int /*song*/, int /*seconds*/) override
    {
        return false;
    }

private:
    mpg123_handle* mp3;
    // size_t buf_size;
    // unsigned char *buffer;
    long rate = 0;
    int channels = 0;
    // thread httpThread;
    bool gotLength = false;
    bool gotMeta = false;
    int length;
    int bytesPut;
    bool streamDone;
    bool opened = false;
    int metaInterval = -1;
    int metaSize = 0;
    int metaCounter = 0;
    char icyData[16 * 256 + 1];
    char* icyPtr;
    int64_t fileSize = 0;

    double totalSeconds = 0;
    std::atomic<uint64_t> totalSize;
    float bitRate = 0;
};

bool MP3Plugin::canHandle(const std::string& name)
{
    auto ext = utils::path_extension(name);
    return ext == "mp3";
}

ChipPlayer* MP3Plugin::fromFile(const std::string& fileName)
{
    return new MP3Player{fileName};
};

ChipPlayer* MP3Plugin::fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo)
{
    return new MP3Player(fifo);
}

} // namespace musix
