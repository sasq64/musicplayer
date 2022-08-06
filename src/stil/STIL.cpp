#include "STIL.hpp"

#include <fstream>

#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/text.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>

#include <crypto/md5.h>

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

STIL::STIL(fs::path const& data_dir) : dataDir(data_dir)
{
    readSTIL();
    readLengths();
}

STIL::~STIL()
{
    stopInitThread = true;
    if (initThread.joinable()) { initThread.join(); }
}

uint64_t STIL::calculateMD5(const std::string& fileName)
{
    auto data = utils::read_file(fileName);
    auto md5 = MD5::calc(data);
    return get<uint64_t>(md5, 0);
}

template <typename S> auto&& getLine(S& stream, std::string& out)
{
    auto&& r = std::getline(stream, out);
    auto n = out.length();
    if (n > 0 && out[n - 1] == 13) { out = out.substr(0, n - 1); }
    return r;
}

void STIL::readSTIL()
{
    STILInfo currentInfo{};
    std::vector<STILInfo> songs;
    if (!fs::exists(dataDir / "STIL.txt")) { return; }

    std::string path;
    std::string what;
    std::string content;
    std::string songComment;
    bool currentSet = false;

    std::ifstream myfile;
    myfile.open(dataDir / "STIL.txt");
    std::string l;
    while (getLine(myfile, l)) {
        if (stopInitThread) { return; }

        if (l.empty() || l[0] == '#') { continue; }

        if (l.length() > 4 && l[4] == ' ' && !what.empty()) {
            content = content + " " + utils::lstrip(l);
        } else {
            if (!content.empty()) {
                if (!what.empty()) {
                    if (songComment.empty() && what == "COMMENT" &&
                        songs.empty() && currentInfo.title.empty() &&
                        currentInfo.name.empty()) {
                        songComment = content;
                        // fmt::print(">{}\n", songComment);
                    } else {
                        if (what == "TITLE") {
                            currentInfo.title = utils::utf8_encode(content);
                        } else if (what == "COMMENT") {
                            currentInfo.comment = utils::utf8_encode(content);
                        } else if (what == "AUTHOR") {
                            currentInfo.author = utils::utf8_encode(content);
                        } else if (what == "ARTIST") {
                            currentInfo.artist = utils::utf8_encode(content);
                        } else if (what == "NAME") {
                            currentInfo.name = utils::utf8_encode(content);
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
                currentInfo.subSong = 1;
                currentInfo.seconds = 0;
                what = "";
                content = "";
            } else if (l[0] == '(') {

                if (currentSet) {
                    if (songComment.empty() && !currentInfo.comment.empty() &&
                        songs.empty() && currentInfo.title.empty() &&
                        currentInfo.name.empty()) {
                        songComment = utils::utf8_encode(content);
                    } else {
                        songs.push_back(currentInfo);
                    }
                    currentInfo = {};
                    currentSet = false;
                }
                currentInfo.subSong = std::stoi(l.substr(2));
                // LOGD("SUBSONG {}", currentInfo.subsong);
                currentInfo.seconds = 0;
                content = "";
                what = "";
            } else {
                auto colon = l.find(':');
                if (colon != std::string::npos) {
                    what = utils::lstrip(l.substr(0, colon));
                    content = l.substr(colon + 2);
                    if (what == "TITLE") {
                        if (currentSet && !currentInfo.title.empty()) {
                            songs.push_back(currentInfo);
                            auto s = currentInfo.subSong;
                            currentInfo = {};
                            currentInfo.subSong = s;
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
    /* for(auto&& [p,info] : stilSongs) { */
    /*     int i = 1; */
    /*     fmt::print("{}\nCOMMENT: {}\n", p, info.comment); */
    /*     for(auto&& song : info.songs) { */
    /*         fmt::print("#{} : {}\n", i, song.title, song.name); */
    /*         i++; */
    /*     } */

    /* } */
}

void STIL::readLengths()
{
    static_assert(sizeof(LengthEntry) == 12, "LengthEntry size incorrect");

    // fmt::print("Lengths {}\n", dataDir.string());
    if (!fs::exists(dataDir / "Songlengths.md5")) { return; }

    uint16_t ll = 0;
    std::string name;
    extraLengths.reserve(30000);
    mainHash.reserve(60000);

    std::ifstream lenFile;
    lenFile.open(dataDir / "Songlengths.md5");
    std::string line;
    uint16_t stilOffset = 0;
    while (std::getline(lenFile, line)) {
        if (stopInitThread) { return; }
        auto n = line.length();
        if (line[n - 1] == 13) { line = line.substr(0, n - 1); }
        if (line[0] == ';') {
            name = line.substr(2);
            auto it = stilSongs.find(name);
            if (it != stilSongs.end()) {
                stilArray.push_back(it->second);
                stilOffset = stilArray.size();
            }
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

            LengthEntry le(key, ll, stilOffset);
            stilOffset = 0;

            // Sadly, this is ~100% of the cost of this function
            mainHash.insert(upper_bound(mainHash.begin(), mainHash.end(), le),
                            le);
        }
    }
}

STIL::STILSong STIL::getInfo(std::vector<uint8_t> const& data)
{
    STILSong result;
    auto md5 = MD5::calc(data);
    auto key = get<uint64_t>(md5, 0);

    auto it = lower_bound(mainHash.begin(), mainHash.end(), key);
    if (it != mainHash.end()) {
        if (it->hash == key) {
            if (it->stil > 0) {
                // fmt::print("Has STIL\n");
                result = stilArray[it->stil - 1];
            }
            result.lengths = getLengths(*it);
        }
    }
    result.title = std::string(reinterpret_cast<const char*>(&data[0x16]), 32);
    result.composer =
        std::string(reinterpret_cast<const char*>(&data[0x36]), 32);
    result.copyright =
        std::string(reinterpret_cast<const char*>(&data[0x56]), 32);

    return result;
}

std::optional<STIL::STILSong> STIL::findSTIL(std::string const& fileName)
{

    if (stilSongs.count(fileName) != 0) { return stilSongs[fileName]; }
    return std::nullopt;
}

std::vector<uint16_t> STIL::getLengths(LengthEntry const& entry)
{
    std::vector<uint16_t> songLengths;
    uint16_t len = entry.length;
    // LOGI("LEN {:04x}", len);
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
    return songLengths;
}

std::vector<uint16_t> STIL::findLengths(uint64_t key)
{

    LOGI("Looking for {:x}", key);

    auto it = lower_bound(mainHash.begin(), mainHash.end(), key);
    if (it != mainHash.end()) {
        if (it->hash != key) {
            LOGW("Song not found");
            return {};
        }
        return getLengths(*it);
    }
    return {};
}

std::vector<uint16_t> STIL::findLengths(std::vector<uint8_t> const& data)
{
    auto md5 = MD5::calc(data);
    auto key = get<uint64_t>(md5, 0);
    return findLengths(key);
}
