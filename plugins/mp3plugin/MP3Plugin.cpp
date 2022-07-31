
#include "MP3Plugin.h"
#include "../../chipplayer.h"

#include <coreutils/fifo.h>
#include <coreutils/split.h>
#include <coreutils/url.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>
#include <coreutils/log.h>

#include <mpg123.h>

#include <set>
#include <unordered_map>
#include <utility>

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

namespace musix {

class MP3Player : public ChipPlayer
{
public:
    explicit MP3Player(std::shared_ptr<utils::Fifo<uint8_t>> _fifo)
        : fifo(std::move(_fifo)), bytesPut(0), totalSize(0)
    {
        int err = mpg123_init();
        mp3 = mpg123_new(nullptr, &err);
        mpg123_param(mp3, MPG123_ADD_FLAGS, MPG123_QUIET, 0);
    }

    int getHZ() override { return rate * channels / 2; }

    bool setParameter(const std::string& param, int32_t v) override
    {
        if (!opened) {
            if (mpg123_open_feed(mp3) != MPG123_OK) {
                throw player_exception("Could open MP3");
            }
            opened = true;
        }
        if (param == "icy-interval") {
            //LOGD("ICY INTERVAL {}", v);
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

    explicit MP3Player(const std::string& fileName)
    {
        int err = mpg123_init();
        mp3 = mpg123_new(nullptr, &err);
        mpg123_param(mp3, MPG123_ADD_FLAGS, MPG123_QUIET, 0);

        if (mpg123_open(mp3, fileName.c_str()) != MPG123_OK) {
            throw player_exception("Could open MP3");
        }
        bytesPut = 1;
        int encoding = 0;
        if (mpg123_getformat(mp3, &rate, &channels, &encoding) != MPG123_OK) {
            throw player_exception("Could not get format");
        }
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
        //LOGD("Destroying MP3Player");

        if (mp3 != nullptr) {
            mpg123_close(mp3);
            mpg123_delete(mp3);
        }
        mpg123_exit();
    }

    void checkMeta()
    {

        if (!gotLength && fileSize > 0) {
            length = mpg123_length(mp3);
            if (length > 0) {
                //LOGD("L {} T {} S {}", length, mpg123_tpf(mp3),
                //     mpg123_spf(mp3));
                length = length / mpg123_spf(mp3) * mpg123_tpf(mp3);
                gotLength = true;
                //LOGD("MP3 LENGTH {}s", length);
                setMeta("length", length);
            }
        }

        int meta = mpg123_meta_check(mp3);
        mpg123_id3v1* v1 = nullptr;
        mpg123_id3v2* v2 = nullptr;
        if ((meta & MPG123_ICY) != 0) {
            char* icydata = nullptr;
            if (mpg123_icy(mp3, &icydata) == MPG123_OK) {
                //LOGD("ICY:{}", icydata);
            }
        }
        if (((meta & MPG123_NEW_ID3) != 0) &&
            mpg123_id3(mp3, &v1, &v2) == MPG123_OK) {

            //LOGV("New metadata");

            if ((v2 != nullptr) && (v2->title != nullptr)) {

                std::string msg;
                for (int i = 0; i < v2->comments; i++) {
                    if (msg.length() != 0) { msg = msg + " "; }
                    msg = msg + v2->comment_list[i].text.p;
                }

                setMeta("title", utils::htmldecode(v2->title->p), "composer",
                        v2->artist != nullptr ? utils::htmldecode(v2->artist->p)
                                              : "",
                        "message", msg, "format", "MP3", "length", length,
                        "channels", channels);
            } else if (v1 != nullptr) {
                setMeta("title", utils::htmldecode(v1->title), "composer",
                        utils::htmldecode(v1->artist), "message", v1->comment,
                        "format", "MP3", "length", length, "channels",
                        channels);
            } else {
                setMeta("format", "MP3", "length", length, "channels",
                        channels);
            }
        }
        if (meta != 0) { mpg123_meta_free(mp3); }
    }

    std::shared_ptr<utils::Fifo<uint8_t>> fifo;

    void putStream(const uint8_t* source, int size)
    {
        if (!opened) {
            if (mpg123_open_feed(mp3) != MPG123_OK) {
                throw player_exception("Could not open MP3");
            }
            opened = true;
        }
        if (source == nullptr) {
            if (size <= 0) { streamDone = true; }
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

                //LOGV("METASIZE %d at offset %d", metaSize, pos);

                if (pos > 0) { mpg123_feed(mp3, source, pos); }
                source += (pos + 1);
                size -= (pos + 1);
                bytesPut += (pos + 1);
                metaCounter = 0;
                icyPtr = icyData.data();
            }

            if (metaSize > 0) {
                int metaBytes = size > metaSize ? metaSize : size;
                //LOGD("Metabytes %d", metaBytes);

                memcpy(icyPtr, source, metaBytes);
                icyPtr += metaBytes;
                *icyPtr = 0;

                size -= metaBytes;
                source += metaBytes;
                metaSize -= metaBytes;

                if (metaSize <= 0) {
                    //LOGD("META: %s", icyData.data());
                    icyPtr = icyData.data();

                    auto parts = utils::split(std::string(icyData.data()), ";");
                    for (const auto& p : parts) {
                        std::vector<std::string> data = utils::split(p, "=", 2);
                        if (data.size() == 2) {
                            if (data[0] == "StreamTitle") {
                                auto title =
                                    data[1].substr(1, data[1].length() - 2);
                                setMeta("sub_title", utils::utf8_encode(title));
                            }
                        }
                    }
                }
            }
        } while (metaInterval > 0 && metaCounter + size > metaInterval);

        if (size > 0) {
            mpg123_feed(mp3, source, size);
            if (metaInterval > 0) metaCounter += size;
        }

        bytesPut += size;
        auto bytesRead = mpg123_framepos(mp3);

        auto inBuffer = bytesPut - bytesRead;

        checkMeta();
    }

    int getSamples(int16_t* target, int noSamples) override
    {

        long buffered = 0;
        mpg123_getstate(mp3, MPG123_BUFFERFILL, &buffered, nullptr);

        if (fifo && (buffered < 1024 * 128 || totalSeconds == 0)) {
            auto sz = fifo->filled();

            if (sz > 0) {
                static std::array<uint8_t, 8192> temp;
                if (sz > temp.size()) { sz = temp.size(); }
                // LOGD("Getting %d bytes from stream", sz);
                fifo->get(temp.data(), sz);
                putStream(temp.data(), sz);
            }
        }

        size_t done = 0;
        if (bytesPut == 0) { return 0; }
        int err = mpg123_read(mp3, reinterpret_cast<unsigned char*>(target),
                              noSamples * 2, &done);

        totalSeconds += (static_cast<double>(done) / (44100 * 4));
        // LOGD("BUFFERED %d SECONDS %d (done %d)", buffered, totalSeconds,
        // done);
        if (totalSeconds > 2) {
            auto r = static_cast<double>(totalSize - buffered) / totalSeconds;
            r = (r * 8) / 1000;
            if (bitRate == 0) {
                bitRate = r;
            } else {
                bitRate = r * 0.25 + bitRate * 0.75;
            }
            // LOGD("Bitrate %f %d kbit (%d) %d", r, bitRate, totalSize,
            // totalSeconds);
            setMeta("bitrate", static_cast<int>(bitRate));
        }

        //if (err != 0 && err != MPG123_NEED_MORE) { LOGD("MP3 Error %d", err); }

        if (err == MPG123_NEW_FORMAT) { return static_cast<int>(done) / 2; }
        if (err == MPG123_NEED_MORE) {
            if (streamDone) { return -1; }
        } else if (err < 0) {
            return err;
        }
        return static_cast<int>(done) / 2;
    }

    bool seekTo(int /*song*/, int /*seconds*/) override { return false; }

private:
    mpg123_handle* mp3;
    // size_t buf_size;
    // unsigned char *buffer;
    long rate = 0;
    int channels = 0;
    // thread httpThread;
    bool gotLength = false;
    bool gotMeta = false;
    long length = 0;
    size_t bytesPut;
    bool streamDone = false;
    bool opened = false;
    int metaInterval = -1;
    int metaSize = 0;
    int metaCounter = 0;
    std::array<char, 16 * 256 + 1> icyData{};
    char* icyPtr = nullptr;
    int64_t fileSize = 0;

    double totalSeconds = 0;
    std::atomic<uint64_t> totalSize{};
    double bitRate = 0;
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
