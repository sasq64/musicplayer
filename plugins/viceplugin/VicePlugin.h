#ifndef VICE_PLAYER_H
#define VICE_PLAYER_H

#include "../../chipplugin.h"

#include <string>
#include <thread>
#include <vector>

namespace musix {

class VicePlugin : public ChipPlugin
{
public:
    virtual std::string name() const override { return "VicePlugin"; }
    VicePlugin() = default;
    VicePlugin(const std::string& dataDir);
    VicePlugin(const unsigned char* data);
    virtual ~VicePlugin();
    virtual bool canHandle(const std::string& name) override;
    virtual ChipPlayer* fromFile(const std::string& fileName) override;

    friend class VicePlayer;

    void setDataDir(std::string const& dd) { dataDir = dd; }
    void readLengths();
    void readSTIL();
    std::vector<uint16_t> findLengths(uint64_t key);

    static uint64_t calculateMD5(const std::string& fileName);

private:
    struct LengthEntry
    {
        uint64_t hash;
        uint16_t length;

        LengthEntry() {}
        LengthEntry(uint64_t h, uint16_t l) : hash(h), length(l) {}
        bool operator<(const LengthEntry& other) const
        {
            return hash < other.hash;
        }
        bool operator<(uint64_t other) const { return hash < other; }
    } __attribute__((packed));

    static std::vector<LengthEntry> mainHash;
    static std::vector<uint16_t> extraLengths;

    std::string dataDir;

    bool stopInitThread = false;

    struct STIL
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
        STILSong() {}
        STILSong(const std::vector<STIL> songs, const std::string& c)
            : songs(songs), comment(c)
        {}
        std::vector<STIL> songs;
        std::string comment;
    };

    static std::unordered_map<std::string, STILSong> stilSongs;

    std::thread initThread;
};

} // namespace musix

#endif // VICE_PLAYER_H
