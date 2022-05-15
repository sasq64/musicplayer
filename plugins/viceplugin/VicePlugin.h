#pragma once

#include "../../chipplugin.h"

#include <filesystem>
#include <string>
#include <thread>
#include <vector>

namespace musix {

class VicePlugin : public ChipPlugin
{
public:
    std::string name() const override { return "VicePlugin"; }
    VicePlugin() = default;
    explicit VicePlugin(const std::string& dataDir);
    ~VicePlugin() override;
    bool canHandle(const std::string& name) override;
    ChipPlayer* fromFile(const std::string& fileName) override;

    friend class VicePlayer;

    void setDataDir(std::string const& dd) { dataDir = dd; }
    void readLengths();
    void readSTIL();
    static std::vector<uint16_t> findLengths(uint64_t key);

    static uint64_t calculateMD5(const std::string& fileName);

private:
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

    static std::vector<LengthEntry> mainHash;
    static std::vector<uint16_t> extraLengths;

    std::filesystem::path dataDir;

    bool stopInitThread = false;

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
        {}
        std::vector<STILInfo> songs;
        std::string comment;
    };

    static std::unordered_map<std::string, STILSong> stilSongs;

    std::thread initThread;
};

} // namespace musix
