#include <cstdint>
#include <fstream>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>
#include <optional>

#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/text.h>
#include <coreutils/utils.h>

#include <crypto/md5.h>

#include <filesystem>
namespace fs = std::filesystem;

namespace {

template <typename T> T get(const std::vector<uint8_t>&, int) {}

template <> uint16_t get(const std::vector<uint8_t>& v, int offset)
{
    return static_cast<unsigned>(v[offset] << 8U) | v[offset + 1];
}

template <> uint32_t get(const std::vector<uint8_t>& v, int offset)
{
    return (static_cast<unsigned>(v[offset + 0]) << 24U) |
           static_cast<unsigned>(v[offset + 1] << 16U) |
           static_cast<unsigned>(v[offset + 2] << 8U) | v[offset + 3];
}

template <> uint64_t get(const std::vector<uint8_t>& v, int offset)
{
    return (static_cast<uint64_t>(get<uint32_t>(v, offset)) << 32U) |
           get<uint32_t>(v, offset + 4);
}

} // namespace

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
        {}
        std::vector<STILInfo> songs;
        std::string comment;
    };

    explicit STIL(fs::path const& data_dir) : dataDir(data_dir)
    {
        readSTIL();
        readLengths();
    }

private:
    std::unordered_map<std::string, STILSong> stilSongs;

    std::thread initThread;
    fs::path dataDir;
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

    static std::vector<uint8_t> calculateMD5(std::vector<uint8_t> const& data)
    {
        uint8_t speed = (data[0] == 'R') ? 60 : 0;
        uint16_t version = get<uint16_t>(data, PSID_VERSION);
        uint16_t initAdr = get<uint16_t>(data, INIT_ADDRESS);
        uint16_t playAdr = get<uint16_t>(data, PLAY_ADDRESS);
        uint16_t songs = get<uint16_t>(data, SONGS);
        uint32_t speedBits = get<uint32_t>(data, SPEED);
        uint16_t flags = get<uint16_t>(data, FLAGS);
        auto offset = (version == 2) ? 126 : 120;

        MD5 md5;
        md5.add(data, offset);
        md5.add(initAdr);
        md5.add(playAdr);
        md5.add(songs);

        for (unsigned i = 0; i < songs; i++) {
            if ((speedBits & (1U << i)) != 0) {
                md5.add(static_cast<uint8_t>(60));
            } else {
                md5.add(speed);
            }
        }

        if ((flags & 0x8U) != 0) { md5.add(static_cast<uint8_t>(2)); }

        return md5.get();
    }

    static uint64_t calculateMD5(const std::string& fileName)
    {
        auto data = utils::read_file(fileName);
        auto md5 = calculateMD5(data);
        auto key = get<uint64_t>(md5, 0);
        return key;
    }

    void readSTIL()
    {
        STILInfo currentInfo{};
        std::vector<STILInfo> songs;
        if (!fs::exists(dataDir / "STILInfo.txt")) { return; }

        std::string path;
        std::string what;
        std::string content;
        std::string songComment;
        bool currentSet = false;

        std::ifstream myfile;
        myfile.open(dataDir / "STILInfo.txt");
        std::string l;
        while (std::getline(myfile, l)) {
            if (stopInitThread) { return; }
            if (l.empty() || l[0] == '#') { continue; }
            // if(count++ == 300) break;
            if (l.length() > 4 && l[4] == ' ' && !what.empty()) {
                content = content + " " + utils::lstrip(l);
            } else {
                if (!content.empty()) {
                    if (!what.empty()) {
                        if (songComment.empty() && what == "COMMENT" &&
                            songs.empty() && currentInfo.title.empty() &&
                            currentInfo.name.empty()) {
                            songComment = content;
                        } else {
                            // LOGD("WHAT:{} = '{}'", what, content);
                            if (what == "TITLE") {
                                currentInfo.title = content;
                            } else if (what == "COMMENT") {
                                currentInfo.comment = content;
                            } else if (what == "AUTHOR") {
                                currentInfo.author = content;
                            } else if (what == "ARTIST") {
                                currentInfo.artist = content;
                            } else if (what == "NAME") {
                                currentInfo.name = content;
                            }
                            currentSet = true;
                        }
                        what = "";
                        content = "";
                    }
                }

                if (l[0] == '/') {
                    if (currentSet) {
                        songs.push_back(currentInfo);
                        currentInfo = {};
                        currentSet = false;
                    }
                    stilSongs[path] = STILSong(songs, songComment);
                    songComment = "";
                    songs.clear();
                    path = l;
                    currentInfo.subsong = 1;
                    currentInfo.seconds = 0;
                    what = "";
                    content = "";
                } else if (l[0] == '(') {

                    if (currentSet) {
                        if (songComment.empty() &&
                            !currentInfo.comment.empty() && songs.empty() &&
                            currentInfo.title.empty() &&
                            currentInfo.name.empty()) {
                            songComment = content;
                        } else {
                            songs.push_back(currentInfo);
                        }
                        currentInfo = {};
                        currentSet = false;
                    }
                    currentInfo.subsong = std::stoi(l.substr(2));
                    // LOGD("SUBSONG {}", currentInfo.subsong);
                    currentInfo.seconds = 0;
                    content = "";
                    what = "";
                } else {
                    auto colon = l.find(':');
                    if (colon != std::string::npos) {
                        what = utils::lstrip(l.substr(0, colon));
                        content = l.substr(colon + 1);
                        if (what == "TITLE") {
                            if (currentSet && !currentInfo.title.empty()) {
                                songs.push_back(currentInfo);
                                auto s = currentInfo.subsong;
                                currentInfo = {};
                                currentInfo.subsong = s;
                                currentSet = false;
                            }
                            if (content[content.size() - 1] == ')') {
                                auto pos = content.rfind('(');
                                auto secs =
                                    utils::split(content.substr(pos + 1), ":");
                                if (secs.size() >= 2) {
                                    int m = std::stoi(secs[0]);
                                    int s = std::stoi(secs[1]);
                                    currentInfo.seconds = s + m * 60;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    void readLengths()
    {
        static_assert(sizeof(LengthEntry) == 10, "LengthEntry size incorrect");
        if (!fs::exists(dataDir / "Songlengths.txt")) { return; }

        uint16_t ll = 0;
        std::string name;
        extraLengths.reserve(30000);

        std::ifstream myfile;
        myfile.open(dataDir / "Songlengths.txt");
        std::string line;
        while (std::getline(myfile, line)) {
            if (stopInitThread) { return; }
            if (line[0] == ';') {
                name = line;
            } else if (line[0] != '[') {
                auto key = from_hex<uint64_t>(line.substr(0, 16));
                auto lengths = utils::split(line.substr(33), " ");
                if (lengths.size() == 1) {
                    auto [mins, secs] = utils::splitn<2>(lengths[0], ":");
                    ll = stoi(mins) * 60 + stoi(secs);
                } else {
                    ll = extraLengths.size() | 0x8000U;
                    for (const auto& sl : lengths) {
                        auto [mins, secs] = utils::splitn<2>(sl, ":");
                        extraLengths.push_back(stoi(mins) * 60 + stoi(secs));
                    }
                    extraLengths.back() |= 0x8000U;
                }

                LengthEntry le(key, ll);

                // Sadly, this is ~100% of the cost of this function
                mainHash.insert(
                    upper_bound(mainHash.begin(), mainHash.end(), le), le);
            }
        }
    }

public:
    std::optional<STILSong> findSTIL(std::string const& fileName)
    {

        if (stilSongs.count(fileName) != 0) { return stilSongs[fileName]; }
        return std::nullopt;
    }

    std::vector<uint16_t> findLengths(uint64_t key)
    {
        std::vector<uint16_t> songLengths;

        LOGI("Looking for {:x}", key);

        auto it = lower_bound(mainHash.begin(), mainHash.end(), key);
        if (it != mainHash.end()) {
            if (it->hash != key) {
                LOGW("Song not found");
                return {};
            }
            uint16_t len = it->length;
            LOGI("LEN {:04x}", len);
            if ((len & 0x8000U) != 0) {
                auto offset = len & 0x7fffU;
                len = 0;
                while ((len & 0x8000U) == 0) {
                    len = extraLengths[offset++];
                    songLengths.push_back(len & 0x7fffU);
                }
            } else {
                songLengths.push_back(len);
            }
        }
        return songLengths;
    }

    std::vector<uint16_t> findLengths(std::vector<uint8_t> const& data)
    {
        auto md5 = calculateMD5(data);
        auto key = get<uint64_t>(md5, 0);
        return findLengths(key);
    }
};
