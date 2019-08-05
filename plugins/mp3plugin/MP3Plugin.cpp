
#include "MP3Plugin.h"
#include "../../chipplayer.h"

#include <coreutils/fifo.h>
#include <coreutils/file.h>
#include <coreutils/split.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>

#define MINIMP3_ONLY_MP3
#define MINIMP3_IMPLEMENTATION
#include "minimp3/minimp3.h"

#include <set>
#include <unordered_map>

namespace musix {

class MP3Player : public ChipPlayer
{
    mp3dec_t mp3d;
    utils::File inFile;
    size_t frame_bytes = 0;
    size_t meta_interval = 0;
    size_t next_meta_start = 0;
    size_t file_size = 0;
    std::shared_ptr<utils::Fifo<uint8_t>> fifo;

    //
    static constexpr size_t Mp3_Bytes_Needed = 256 * 16 + 4096;
    static constexpr size_t Samples_In_Frame = 1152;
    static constexpr size_t Max_Frame_Size = 2250;

public:
    MP3Player(std::shared_ptr<utils::Fifo<uint8_t>> fifo) : fifo(fifo)
    {
        mp3dec_init(&mp3d);
    }

    MP3Player(const std::string& fileName)
        : inFile(fileName),
          fifo(std::make_shared<utils::Fifo<uint8_t>>(128 * 1024))
    {
        mp3dec_init(&mp3d);
    }

    bool setParameter(const std::string& param, int32_t v) override
    {
        if (param == "icy-interval") {
            meta_interval = v;
            next_meta_start = v;
            return true;
        }
        if (param == "size") {
            file_size = v;
            return true;
        }
        return false;
    }

    ~MP3Player() override {}

    void decode_meta(uint8_t* icyData)
    {
        LOGD("META: %s", icyData);
        auto parts = utils::split(std::string((char*)icyData), ";");
        for (const auto& p : parts) {
            std::vector<std::string> data = utils::split(p, "=", 2);
            if (data.size() == 2) {
                if (data[0] == "StreamTitle") {
                    auto title = data[1].substr(1, data[1].length() - 2);
                    setMeta("sub_title", utils::utf8_encode(title));
                }
            }
        }
    }

    void check_meta()
    {
        if (meta_interval == 0)
            return;
        // If fifo contains start AND end of meta data, extract it.
        // (This means fifo needs to be at least 16*256 + 2881 bytes
        //

        auto filled = fifo->filled();

        if (frame_bytes + 2200 > next_meta_start) {
            uint8_t meta_data[16 * 256];
            uint8_t temp[2200];
            uint8_t mp3_bytes = next_meta_start - frame_bytes;
            // Read remaining mp3 bytes + first meta byte
            fifo->get(temp, mp3_bytes + 1);
            auto meta_size = temp[mp3_bytes] * 16;
            // Read all meta bytes
            fifo->get(meta_data, meta_size - 1);
            // Put back mp3 bytes
            fifo->insert(temp, mp3_bytes);

            next_meta_start += meta_interval;
        }
    }

    template <typename T> static T read(uint8_t* data)
    {
        return (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
    }

    void parse_id3(uint8_t* data)
    {
        if (memcmp(data, "ID3", 3) == 0) {
            auto version = data[3];
            auto flags = data[5];
            auto sz = read<int32_t>(&data[6]);

            printf("ID3 flags %x size %d\n", flags, sz);

            auto* ptr = &data[10];
            auto* endp = &data[sz];
            while (ptr < endp) {
                auto tag = std::string((char*)ptr, 4);
                sz = read<int32_t>(&ptr[4]);
                if (sz == 0)
                    break;
                printf("Tag %s sz %d\n", tag.c_str(), sz);
                if (tag == "TIT2") {
                    auto title = std::string((char*)&ptr[11], sz-1);
                    printf("Title:%s\n", title.c_str());
                    addMeta("title", title);
                }
                ptr += (sz + 10);
            }
            setMeta();
        }
    }

    // Read a single frame from the fifo
    int decode_frame(int16_t* target)
    {
        mp3dec_frame_info_t info;
        int samples;
        int bytes = fifo->get(Max_Frame_Size, [&](uint8_t* data, int sz) {
            parse_id3(data);
            samples = mp3dec_decode_frame(&mp3d, data, sz, target, &info);
            // printf("Read %d bytes from fifo\n", info.frame_bytes);
            return info.frame_bytes;
        });
        frame_bytes += bytes;
        return samples;
    }

    // Decode incoming mp3 bytes and analyze frames
    int decode(int16_t* target, int max_samples)
    {
        check_meta();

        int out_pos = 0;
        // We need enough incoming data to parse complete meta data
        // section and let minimp3 look ahead a bit
        while (fifo->filled() > Mp3_Bytes_Needed &&
               max_samples / 2 > Samples_In_Frame) {
            auto samples = decode_frame(&target[out_pos]);
            // printf("Decoded %d samples\n", samples);
            out_pos += samples * 2;
            max_samples -= samples * 2;
        }
        return out_pos;
    }

    virtual int getSamples(int16_t* target, int noSamples) override
    {
        static uint8_t temp[8192];

        // If we have a file, try to fill the fifo
        int left = fifo->left();
        while (inFile && left > 0) {
            int rc = inFile.read(&temp[0], left);
            // printf("Read %d bytes\n", rc);
            if (rc <= 0) {
                inFile.close();
                break;
            }
            fifo->put(temp, rc);
            left = fifo->left();
        }

        int samples = decode(target, noSamples);
        // printf("Samples %d\n", samples);
        return samples;
    }

    virtual bool seekTo(int /*song*/, int /*seconds*/) override
    {
        return false;
    }
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
