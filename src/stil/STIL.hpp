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
        uint16_t stil;

        LengthEntry() = default;
        LengthEntry(uint64_t h, uint16_t l, uint16_t st)
            : hash(h), length(l), stil(st)
        {
        }
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
        int subSong;
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
        STILSong(const std::vector<STILInfo>& _songs,
                 const std::string& _comment)
            : songs(_songs), comment(_comment)
        {
        }
        std::string title;
        std::string composer;
        std::string copyright;

        std::vector<STILInfo> songs;
        std::string comment;
        std::vector<uint16_t> lengths;
    };

    explicit STIL(std::filesystem::path const& data_dir);
    ~STIL();

    std::vector<uint16_t> getLengths(LengthEntry const& entry);

private:
    std::unordered_map<std::string, STILSong> stilSongs;
    std::vector<STILSong> stilArray;

    std::thread initThread;
    std::filesystem::path dataDir;
    bool stopInitThread{};

    static constexpr uint16_t a2h(char c)
    {
        return c <= '9' ? c - '0' : (tolower(c) - 'a' + 10);
    }

    template <typename T> static constexpr T from_hex(const std::string& s)
    {
        T t = 0;
        const auto* ptr = s.c_str();
        while (*ptr) {
            t = (t << 4U) | a2h(*ptr++);
        }
        return t;
    }

public:
    static uint64_t calculateMD5(const std::string& fileName);

    void readSTIL();
    void readLengths();

    std::optional<STILSong> findSTIL(std::string const& fileName);
    STILSong getInfo(std::vector<uint8_t> const& data);
    std::vector<uint16_t> findLengths(uint64_t key);
    std::vector<uint16_t> findLengths(std::vector<uint8_t> const& data);
};
