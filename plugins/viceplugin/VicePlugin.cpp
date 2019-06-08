#include <coreutils/file.h>
#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/utils.h>
#include <crypto/md5.h>

extern "C"
{
#include "drive.h"
#include "gfxoutput.h"
#include "init.h"
#include "initcmdline.h"
#include "lib.h"
#include "machine.h"
#include "maincpu.h"
#include "psid.h"
#include "resources.h"
#include "sid/sid.h"
#include "sound.h"
#include "sysfile.h"

    void psid_play(short* buf, int size);
    const char* psid_get_name();
    const char* psid_get_author();
    const char* psid_get_copyright();
}

#include "../../chipplayer.h"
#include "VicePlugin.h"

#include <algorithm>
#include <set>

int console_mode = 1;
int vsid_mode = 1;
int video_disabled_mode = 1;

namespace musix {

using namespace utils;

static bool videomode_is_ntsc = false;
static bool videomode_is_forced = false;
static int sid = 3; // SID_MODEL_DEFAULT;// SID_MODEL_8580;
static bool sid_is_forced = true;

namespace {

template <typename T> const T get(const std::vector<uint8_t>& v, int offset) {}

template <> const uint16_t get(const std::vector<uint8_t>& v, int offset)
{
    return (v[offset] << 8) | v[offset + 1];
}

template <> const uint32_t get(const std::vector<uint8_t>& v, int offset)
{
    return (v[offset] << 24) | (v[offset + 1] << 16) | (v[offset + 2] << 8) |
           v[offset + 3];
}

template <> const uint64_t get(const std::vector<uint8_t>& v, int offset)
{
    return ((uint64_t)get<uint32_t>(v, offset) << 32) |
           get<uint32_t>(v, offset + 4);
}

} // namespace

enum
{
    MAGICID = 0,
    PSID_VERSION = 4,
    DATA_OFFSET = 6,
    LOAD_ADDRESS = 8,
    INIT_ADDRESS = 0xA,
    PLAY_ADDRESS = 0xC,
    SONGS = 0xE,
    START_SONG = 0x10,
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

        for (int i = 0; i < songs; i++) {
            if ((speedBits & (1 << i)) != 0) {
                md5.add((uint8_t)60);
            } else {
                md5.add(speed);
            }
        }

        if ((flags & 0x8) != 0) {
            md5.add((uint8_t)2);
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
        if (init_main() < 0) {
            // archdep_startup_log_error("Failed to init main");
            return false;
        }

        return true;
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
        LOGD("Loaded %s -> %d", sidFile, ret);
        if (ret != 0)
            throw player_exception("Not a sid file");

        File f{sidFile};
        auto data = f.readAll();
        auto md5 = calculateMD5(data);
        auto key = get<uint64_t>(md5, 0);
        LOGD("MD5: [%02x] %08x", md5, key);
        songLengths = plugin.findLengths(key);

        std::string realPath = sidFile;
        if (sidFile.find("C64Music%2f") != std::string::npos) {
            realPath = utils::urldecode(sidFile, ":/\\?;");
        }

        int defaultSong;
        int songs = psid_tunes(&defaultSong);
        currentSong = --defaultSong;
        LOGD("DEFSONG: %d", defaultSong);
        currentLength = 0;
        currentPos = 0;
        nextCheckPos = currentPos + 44100;
        if ((int)songLengths.size() > defaultSong) {
            currentLength = songLengths[defaultSong];
        }
        LOGD("Length:%d", currentLength);
        std::string msg = "NO STIL INFO";
        std::string sub_title;
        auto pos = realPath.find("C64Music/");
        currentInfo = 0;
        if (pos != std::string::npos) {
            auto p = realPath.substr(pos + 8);
            LOGD("SIDFILE:%s", p);
            if (VicePlugin::stilSongs.count(p)) {
                currentStil = VicePlugin::stilSongs[p];
                msg = currentStil.comment;

                for (int i = 0; i < (int)currentStil.songs.size(); i++) {
                    auto& s = currentStil.songs[i];
                    LOGD("#%d: %s", s.subsong, s.title);
                    if (s.subsong == defaultSong + 1) {
                        currentInfo = i;
                        sub_title = s.title; // sub_title + s.title + " ";
                        if (sub_title == "")
                            sub_title = s.name;

                        if (msg == "")
                            msg = s.comment;
                        break;
                    }
                }
            }
        }
        setMeta("title", utf8_encode(psid_get_name()), "composer",
                utf8_encode(psid_get_author()), "copyright",
                utf8_encode(psid_get_copyright()), "format", "C64 Sid", "songs",
                songs, "message", utf8_encode(msg), "sub_title",
                utf8_encode(sub_title), "length", currentLength, "startSong",
                defaultSong);

        c64_song_init();
    }

    ~VicePlayer() { psid_set_tune(-1); }

    virtual bool seekTo(int song, int seconds = -1)
    {
        if (song >= 0) {
            currentSong = song;
            psid_set_tune(song + 1);
            c64_song_init();
            currentLength = 0;
            currentPos = 0;
            if ((int)songLengths.size() > song) {
                currentLength = songLengths[song];
            }

            LOGD("Length:%d, SONG %d", currentLength, song);
            std::string sub_title;
            std::string msg = currentStil.comment;
            for (int i = 0; i < (int)currentStil.songs.size(); i++) {
                auto& s = currentStil.songs[i];
                LOGD("#%d: %s", s.subsong, s.title);
                if (s.subsong == song + 1) {
                    currentInfo = i;
                    sub_title = s.title; // sub_title + s.title + " ";
                    if (sub_title == "")
                        sub_title = s.name;
                    if (s.comment != "")
                        msg = s.comment;
                    break;
                }
            }

            setMeta("length", currentLength, "sub_title",
                    utf8_encode(sub_title), "message", utf8_encode(msg));
            return true;
        }
        return false;
    }

    virtual int getSamples(int16_t* target, int size)
    {
        currentPos += (size / 2);

        if (currentPos > nextCheckPos) {
            int sec = currentPos / 44100;
            nextCheckPos = currentPos + 44100;
            for (int i = currentInfo + 1; i < (int)currentStil.songs.size();
                 i++) {
                auto& s = currentStil.songs[i];
                if (s.subsong == currentSong + 1) {
                    if (s.seconds > 0 && sec >= s.seconds) {
                        LOGD("Found new info");
                        currentInfo = i;
                        if (s.comment != "")
                            setMeta("sub_title", utf8_encode(s.title),
                                    "message", utf8_encode(s.comment));
                        else
                            setMeta("sub_title", utf8_encode(s.title));
                        break;
                    }
                }
            }
        }

        // LOGD("%d vs %d", currentPos, currentLength*44100);
        // if(currentLength > 0 && currentPos > currentLength*44100)
        //  return -1;
        psid_play(target, size);
        return size;
    }

    VicePlugin& plugin;

    uint32_t currentLength;
    uint32_t currentPos;
    uint32_t nextCheckPos;
    int currentInfo;
    int currentSong;
    std::vector<uint16_t> songLengths;
    VicePlugin::STILSong currentStil;
};

std::vector<VicePlugin::LengthEntry> VicePlugin::mainHash;
std::vector<uint16_t> VicePlugin::extraLengths;
std::unordered_map<std::string, VicePlugin::STILSong> VicePlugin::stilSongs;

VicePlugin::VicePlugin(const std::string& dataDir) : dataDir(dataDir)
{
    VicePlayer::init(dataDir + "/c64");
    initThread = std::thread([=] {
        readLengths();
        readSTIL();
    });
}

/* VicePlugin::VicePlugin(const unsigned char *data) { */
/*     utils::makedir("c64"); */

/*     FILE *fp; */
/*     fp = fopen("c64/basic", "wb"); */
/*     fwrite(&data[0], 1, 8192, fp); */
/*     fclose(fp); */

/*     fp = fopen("c64/chargen", "wb"); */
/*     fwrite(&data[8192], 1, 4096, fp); */
/*     fclose(fp); */

/*     fp = fopen("c64/kernal", "wb"); */
/*     fwrite(&data[8192 + 4096], 1, 8192, fp); */
/*     fclose(fp); */
/*     VicePlayer::init("c64"); */

/*     readLengths(); */
/* } */

// static File find_file(const std::string &name) {
//  return File::findFile(current_exe_path() + ":" + File::getAppDir(), name);
//}

void VicePlugin::readSTIL()
{

    STIL current;
    std::vector<STIL> songs;
    File f = File(dataDir + "/STIL.txt");
    if (!f.exists())
        return;
    // int subsong = -1;
    std::string path;
    std::string what;
    std::string content;
    std::string songComment;
    bool currentSet = false;
    // int seconds = 0;
    // int count = 0;
    for (auto l : f.getLines()) {
        if (stopInitThread)
            return;
        // LOGD("'%c' : %s", l[0], l);
        if (l == "" || l[0] == '#')
            continue;
        // if(count++ == 300) break;
        if (l.length() > 4 && l[4] == ' ' && what != "") {
            content = content + " " + lstrip(l);
        } else {
            if (what != "" && content != "") {
                if (songComment == "" && what == "COMMENT" &&
                    songs.size() == 0 && current.title == "" &&
                    current.name == "") {
                    songComment = content;
                } else {
                    // LOGD("WHAT:%s = '%s'", what, content);
                    if (what == "TITLE")
                        current.title = content;
                    else if (what == "COMMENT")
                        current.comment = content;
                    else if (what == "AUTHOR")
                        current.author = content;
                    else if (what == "ARTIST")
                        current.artist = content;
                    else if (what == "NAME")
                        current.name = content;
                    currentSet = true;
                }
                what = "";
                content = "";
            }

            if (l[0] == '/') {
                if (currentSet) {
                    songs.push_back(current);
                    current = STIL();
                    currentSet = false;
                }
                stilSongs[path] = STILSong(songs, songComment);
                songComment = "";
                songs.clear();
                path = l;
                current.subsong = 1;
                current.seconds = 0;
                what = "";
                content = "";
            } else if (l[0] == '(') {

                if (currentSet) {
                    if (songComment == "" && current.comment != "" &&
                        songs.size() == 0 && current.title == "" &&
                        current.name == "") {
                        songComment = content;
                    } else {
                        songs.push_back(current);
                    }
                    current = STIL();
                    currentSet = false;
                }
                current.subsong = atoi(l.substr(2).c_str());
                // LOGD("SUBSONG %d", current.subsong);
                current.seconds = 0;
                content = "";
                what = "";
            } else {
                auto colon = l.find(":");
                if (colon != std::string::npos) {
                    what = lstrip(l.substr(0, colon));
                    content = l.substr(colon + 1);
                    if (what == "TITLE") {
                        if (currentSet && current.title != "") {
                            songs.push_back(current);
                            auto s = current.subsong;
                            current = STIL();
                            current.subsong = s;
                            currentSet = false;
                        }
                        if (content[content.size() - 1] == ')') {
                            auto pos = content.rfind("(");
                            auto secs = split(content.substr(pos + 1), ":");
                            if (secs.size() >= 2) {
                                int m = atoi(secs[0]);
                                int s = atoi(secs[1]);
                                current.seconds = s + m * 60;
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
    if (initThread.joinable())
        initThread.join();
}

static const std::set<std::string> ext{".sid", ".psid", ".rsid", ".2sid",
                                       ".mus"};

bool VicePlugin::canHandle(const std::string& name)
{
    for (std::string x : ext) {
        if (utils::endsWith(name, x))
            return true;
    }
    return false;
}

ChipPlayer* VicePlugin::fromFile(const std::string& fileName)
{
    if (initThread.joinable())
        initThread.join();
    try {
        return new VicePlayer{*this, fileName};
    } catch (player_exception& e) {
        return nullptr;
    }
}

constexpr uint16_t a2h(char c)
{
    return c <= '9' ? c - '0' : (tolower(c) - 'a' + 10);
}

template <typename T> T from_hex(const std::string& s)
{
    T t = 0;
    auto* ptr = s.c_str();
    while (*ptr) {
        t = (t << 4) | a2h(*ptr++);
    }
    return t;
}

void VicePlugin::readLengths()
{
    static_assert(sizeof(LengthEntry) == 10);
    File fp{dataDir + "/Songlengths.txt"};
    if (!fp.exists())
        return;
    std::string secs, mins;
    uint16_t ll = 0;
    std::string name;
    extraLengths.reserve(30000);
    for (const auto& l : fp.getLines()) {
        if (stopInitThread)
            return;
        if (l[0] == ';')
            name = l;
        else if (l[0] != '[') {
            auto key = from_hex<uint64_t>(l.substr(0, 16));
            if (name.find("Comic") != std::string::npos)
                LOGI("%s %x", name, key);
            auto lengths = split(l.substr(33), " ");
            if (lengths.size() == 1) {
                tie(mins, secs) = splitn<2>(lengths[0], ":");
                ll = stoi(mins) * 60 + stoi(secs);
            } else {
                ll = extraLengths.size() | 0x8000;
                for (const auto& sl : lengths) {
                    tie(mins, secs) = splitn<2>(sl, ":");
                    extraLengths.push_back(stoi(mins) * 60 + stoi(secs));
                }
                extraLengths.back() |= 0x8000;
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

    LOGI("Looking for %x", key);

    auto it = lower_bound(mainHash.begin(), mainHash.end(), key);
    if (it != mainHash.end()) {
        if (it->hash != key) {
            LOGW("Song not found");
            return {};
        }
        uint16_t len = it->length;
        LOGI("LEN %04x", len);
        if ((len & 0x8000) != 0) {
            auto offset = len & 0x7fff;
            len = 0;
            while ((len & 0x8000) == 0) {
                len = extraLengths[offset++];
                songLengths.push_back(len & 0x7fff);
            }
        } else
            songLengths.push_back(len);
    }
    return songLengths;
}

uint64_t VicePlugin::calculateMD5(const std::string& fileName)
{
    utils::File f{fileName};
    auto data = f.readAll();
    auto md5 = VicePlayer::calculateMD5(data);
    auto key = get<uint64_t>(md5, 0);
    return key;
}

} // namespace musix
