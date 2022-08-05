
#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/text.h>
#include <coreutils/url.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>
#include <crypto/md5.h>

#include <filesystem>
#include <string>
namespace fs = std::filesystem;

#include "psid_includes.h"

#include "../../chipplayer.h"
#include "VicePlugin.h"

#include <algorithm>
#include <set>

int console_mode = 1;
int vsid_mode = 1;
int video_disabled_mode = 1;

namespace musix {

static bool videomode_is_ntsc = false;
static bool videomode_is_forced = false;
static int sid = 3; // SID_MODEL_DEFAULT;// SID_MODEL_8580;
static bool sid_is_forced = true;

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

class VicePlayer : public ChipPlayer
{
public:
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

        if ((flags & 0x8U) != 0) {
            md5.add(static_cast<uint8_t>(2));
        }

        return md5.get();
    }

    static bool init(const std::string& c64Dir)
    {
        maincpu_early_init();
        machine_setup_context();
        drive_setup_context();
        machine_early_init();
        sysfile_init("C64");
        gfxoutput_early_init();
        if (init_resources() < 0) {
            // archdep_startup_log_error("Failed to init resources");
            return false;
        }

        if (resources_set_defaults() < 0) {
            // archdep_startup_log_error("Cannot set defaults.\n");
            return false;
        }

        resources_set_int("SidResidSampling", 0);
        resources_set_int("VICIIVideoCache", 0);
        resources_set_string("Directory", c64Dir.c_str());
        return init_main() >= 0;
    }

    static void c64_song_init()
    {
        /* Set default, potentially overridden by reset. */
        resources_set_int("MachineVideoStandard", videomode_is_ntsc
                                                      ? MACHINE_SYNC_NTSC
                                                      : MACHINE_SYNC_PAL);

        /* Default to 6581 in case tune doesn't specify. */
        resources_set_int("SidModel", sid);

        /* Reset C64, which also initializes PSID for us. */
        machine_trigger_reset(MACHINE_RESET_MODE_SOFT);

        /* Now force video mode if we are asked to. */
        if (videomode_is_forced) {
            resources_set_int("MachineVideoStandard", videomode_is_ntsc
                                                          ? MACHINE_SYNC_NTSC
                                                          : MACHINE_SYNC_PAL);
        }

        /* Force the SID model if told to in the settings */
        if (sid_is_forced) {
            resources_set_int("SidModel", sid);
        }
    }

    VicePlayer(VicePlugin& plugin, const std::string& sidFile) : plugin(plugin)
    {
        int ret = psid_load_file(sidFile.c_str());
        LOGD("Loaded {} -> {}", sidFile, ret);
        if (ret != 0) {
            throw player_exception("Not a sid file");
        }

        auto data = utils::read_file(sidFile);
        auto md5 = calculateMD5(data);
        auto key = get<uint64_t>(md5, 0);
        // LOGD("MD5: [%02x] %08x", md5, key);
        songLengths = musix::VicePlugin::findLengths(key);

        std::string realPath = sidFile;
        if (sidFile.find("C64Music%2f") != std::string::npos) {
            realPath = utils::urldecode(sidFile, ":/\\?;");
        }

        int defaultSong = 0;
        int songs = psid_tunes(&defaultSong);
        currentSong = --defaultSong;
        LOGD("DEFSONG: {}", defaultSong);
        currentLength = 0;
        currentPos = 0;
        nextCheckPos = currentPos + 44100;
        if (static_cast<int>(songLengths.size()) > defaultSong) {
            currentLength = songLengths[defaultSong];
        }
        LOGD("Length:{}", currentLength);
        std::string msg = "NO STILInfo INFO";
        std::string sub_title;
        auto pos = realPath.find("C64Music/");
        currentInfo = 0;
        if (pos != std::string::npos) {
            auto p = realPath.substr(pos + 8);
            if (VicePlugin::stilSongs.count(p) != 0) {
                currentStil = VicePlugin::stilSongs[p];
                msg = currentStil.comment;

                for (size_t i = 0; i < currentStil.songs.size(); i++) {
                    auto& s = currentStil.songs[i];
                    LOGD("#{}: {}", s.subsong, s.title);
                    if (s.subsong == defaultSong + 1) {
                        currentInfo = i;
                        sub_title = s.title; // sub_title + s.title + " ";
                        if (sub_title.empty()) {
                            sub_title = s.name;
                        }

                        if (msg.empty()) {
                            msg = s.comment;
                        }
                        break;
                    }
                }
            }
        }
        setMeta("title", utils::utf8_encode(psid_get_name()), "composer",
                utils::utf8_encode(psid_get_author()), "copyright",
                utils::utf8_encode(psid_get_copyright()), "format", "C64 Sid",
                "songs", songs, "message", utils::utf8_encode(msg), "sub_title",
                utils::utf8_encode(sub_title), "length", currentLength,
                "startSong", defaultSong);

        c64_song_init();
    }

    ~VicePlayer() override { psid_set_tune(-1); }

    bool seekTo(int song, int /*seconds*/) override
    {
        if (song >= 0) {
            currentSong = song;
            psid_set_tune(song + 1);
            c64_song_init();
            currentLength = 0;
            currentPos = 0;
            if (static_cast<int>(songLengths.size()) > song) {
                currentLength = songLengths[song];
            }

            LOGD("Length:{}, SONG {}", currentLength, song);
            std::string sub_title;
            std::string msg = currentStil.comment;
            for (size_t i = 0; i < currentStil.songs.size(); i++) {
                auto& s = currentStil.songs[i];
                LOGD("#{}: {}", s.subsong, s.title);
                if (s.subsong == song + 1) {
                    currentInfo = i;
                    sub_title = s.title; // sub_title + s.title + " ";
                    if (sub_title.empty()) {
                        sub_title = s.name;
                    }
                    if (!s.comment.empty()) {
                        msg = s.comment;
                    }
                    break;
                }
            }

            setMeta("length", currentLength, "sub_title",
                    utils::utf8_encode(sub_title), "message",
                    utils::utf8_encode(msg));
            return true;
        }
        return false;
    }

    int getSamples(int16_t* target, int size) override
    {
        currentPos += (size / 2);

        if (currentPos > nextCheckPos) {
            int sec = currentPos / 44100;
            nextCheckPos = currentPos + 44100;
            for (size_t i = currentInfo + 1; i < currentStil.songs.size();
                 i++) {
                auto& s = currentStil.songs[i];
                if (s.subsong == currentSong + 1) {
                    if (s.seconds > 0 && sec >= s.seconds) {
                        LOGD("Found new info");
                        currentInfo = i;
                        if (!s.comment.empty()) {
                            setMeta("sub_title", utils::utf8_encode(s.title),
                                    "message", utils::utf8_encode(s.comment));
                        } else {
                            setMeta("sub_title", utils::utf8_encode(s.title));
                        }
                        break;
                    }
                }
            }
        }

        // LOGD("{} vs {}", currentPos, currentLength*44100);
        // if(currentLength > 0 && currentPos > currentLength*44100)
        //  return -1;
        psid_play(target, size);
        return size;
    }

    VicePlugin& plugin;

    int32_t currentLength;
    int32_t currentPos;
    int32_t nextCheckPos;
    size_t currentInfo;
    int currentSong;
    std::vector<uint16_t> songLengths;
    VicePlugin::STILSong currentStil;
};

std::vector<VicePlugin::LengthEntry> VicePlugin::mainHash;
std::vector<uint16_t> VicePlugin::extraLengths;
std::unordered_map<std::string, VicePlugin::STILSong> VicePlugin::stilSongs;

VicePlugin::VicePlugin(const std::string& dataDir) : dataDir(dataDir)
{
    if (!VicePlayer::init(dataDir + "/c64")) {
        throw player_exception("Could not init vice");
    }
    initThread = std::thread([=] {
        readLengths();
        readSTIL();
    });
}

void VicePlugin::readSTIL()
{
    STILInfo currentInfo{};
    std::vector<STILInfo> songs;
    if (!fs::exists(dataDir / "STILInfo.txt")) {
        return;
    }

    std::string path;
    std::string what;
    std::string content;
    std::string songComment;
    bool currentSet = false;

    std::ifstream myfile;
    myfile.open(dataDir / "STILInfo.txt");
    std::string l;
    while (std::getline(myfile, l)) {
        if (stopInitThread) {
            return;
        }
        if (l.empty() || l[0] == '#') {
            continue;
        }
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
                    if (songComment.empty() && !currentInfo.comment.empty() &&
                        songs.empty() && currentInfo.title.empty() &&
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

VicePlugin::~VicePlugin()
{
    LOGD("VicePlugin destroy\n");
    machine_shutdown();
    stopInitThread = true;
    if (initThread.joinable()) {
        initThread.join();
    }
}

static const std::set<std::string> ext{".sid", ".psid", ".rsid", ".2sid",
                                       ".mus"};

bool VicePlugin::canHandle(const std::string& name)
{
    for (const auto& x : ext) {
        if (utils::endsWith(name, x)) {
            return true;
        }
    }
    return false;
}

ChipPlayer* VicePlugin::fromFile(const std::string& fileName)
{
    if (initThread.joinable()) {
        initThread.join();
    }
    return new VicePlayer{*this, fileName};
}

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

void VicePlugin::readLengths()
{
    static_assert(sizeof(LengthEntry) == 10, "LengthEntry size incorrect");
    if (!fs::exists(dataDir / "Songlengths.txt")) {
        return;
    }

    uint16_t ll = 0;
    std::string name;
    extraLengths.reserve(30000);

    std::ifstream myfile;
    myfile.open(dataDir / "Songlengths.txt");
    std::string line;
    while (std::getline(myfile, line)) {
        if (stopInitThread) {
            return;
        }
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
            mainHash.insert(upper_bound(mainHash.begin(), mainHash.end(), le),
                            le);
        }
    }
}

std::vector<uint16_t> VicePlugin::findLengths(uint64_t key)
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

uint64_t VicePlugin::calculateMD5(const std::string& fileName)
{
    auto data = utils::read_file(fileName);
    auto md5 = VicePlayer::calculateMD5(data);
    auto key = get<uint64_t>(md5, 0);
    return key;
}

} // namespace musix
