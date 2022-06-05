#pragma once

#include <cstdint>
#include <filesystem>
#include <optional>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>

class STIL
{
public:
#pragma pack(push, 1)
    struct LengthEntry
    {
        uint64_t hash;
        uint16_t length;

        LengthEntry() = default;
        LengthEntry(uint64_t h, uint16_t l) : hash(h), length(l) {}
        bool operator<(const LengthEntry& other) const
        {
            return hash < other.hash;
        }
        bool operator<(uint64_t other) const { return hash < other; }
    }; //__attribute__((packed));
#pragma pack(pop)

    std::vector<LengthEntry> mainHash;
    std::vector<uint16_t> extraLengths;

    struct STILInfo
    {
        int subsong;
        int seconds;
        std::string title;
        std::string name;
        std::string artist;
        std::string author;
        std::string comment;
    };

    struct STILSong
    {
        STILSong() = default;
        STILSong(const std::vector<STILInfo>& sngs, const std::string& c)
            : songs(sngs), comment(c)
        {
        }
        std::vector<STILInfo> songs;
        std::string comment;
    };

    explicit STIL(std::filesystem::path const& data_dir);
    ~STIL();

private:
    std::unordered_map<std::string, STILSong> stilSongs;

    std::thread initThread;
    std::filesystem::path dataDir;
    bool stopInitThread{};

    constexpr uint16_t a2h(char c)
    {
        return c <= '9' ? c - '0' : (tolower(c) - 'a' + 10);
    }

    template <typename T> T from_hex(const std::string& s)
    {
        T t = 0;
        const auto* ptr = s.c_str();
        while (*ptr) {
            t = (t << 4U) | a2h(*ptr++);
        }
        return t;
    }

    enum
    {
        // MAGICID = 0,
        PSID_VERSION = 4,
        // DATA_OFFSET = 6,
        // LOAD_ADDRESS = 8,
        INIT_ADDRESS = 0xA,
        PLAY_ADDRESS = 0xC,
        SONGS = 0xE,
        // START_SONG = 0x10,
        SPEED = 0x12,
        FLAGS = 0x76
    };

public:
    static std::vector<uint8_t> calculateMD5(std::vector<uint8_t> const& data);
    static uint64_t calculateMD5(const std::string& fileName);

    void readSTIL();
    void readLengths();

    std::optional<STILSong> findSTIL(std::string const& fileName);
    std::vector<uint16_t> findLengths(uint64_t key);
    std::vector<uint16_t> findLengths(std::vector<uint8_t> const& data);
};
