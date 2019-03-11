
#include "UADEPlugin.h"

#include "../../chipplayer.h"

#include <coreutils/file.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>
#include <set>
#include <thread>
#include <uade/uade.h>
#include <unordered_map>
#ifdef _WIN32
#include <direct.h>
#define chdir _chdir
#endif

static std::thread uadeThread;
extern "C" void uade_run_thread(void (*f)(void*), void* data) {
    LOGD("Starting thread");
    try {
        uadeThread = std::thread(f, data);
    } catch(std::exception e) {
        puts(e.what());
    }
}

extern "C" void uade_wait_thread() {
    uadeThread.join();
}

namespace musix {

using namespace std;
using namespace utils;

class UADEPlayer : public ChipPlayer {
public:
    UADEPlayer(const std::string& dataDir)
        : dataDir(dataDir), valid(false), state(nullptr) {}

    static struct uade_file* amigaloader(const char* name,
                                         const char* playerdir, void* context,
                                         struct uade_state* state) {
        LOGD("Trying to load '%s' from '%s'", name, playerdir);
        UADEPlayer* up = static_cast<UADEPlayer*>(context);
        string fileName = name;

        if(endsWith(fileName, "SMPL.set"))
            fileName =  up->loadDir / "set.smpl";
        else if(up->uadeFile) {
            fileName = up->loadDir / up->baseName + "." +
                       path_prefix(fileName);
            LOGD("Translated back to '%s'", fileName);
        } else if(up->currentFileName.find(fileName) == 0) {
            LOGD("Restoring filename %s back to '%s'", fileName,
                 up->currentFileName);
            fileName = up->currentFileName;
        }

        struct uade_file* f =
            uade_load_amiga_file(fileName.c_str(), playerdir, state);
        return f;
    }

    bool load(string fileName) {

		string currDir = File::cwd();

        /* char currdir[2048]; */
        /* if(!getcwd(currdir, sizeof(currdir))) */
        /*     return false; */

        int ok = chdir(dataDir.c_str());

        struct uade_config* config = uade_new_config();
        uade_config_set_option(config, UC_ONE_SUBSONG, NULL);
        uade_config_set_option(config, UC_IGNORE_PLAYER_CHECK, NULL);
        uade_config_set_option(config, UC_NO_EP_END, NULL);
        // uade_config_set_option(config, UC_VERBOSE, "true");
        uade_config_set_option(config, UC_BASE_DIR, ".");
        state = uade_new_state(config, 1);
        free(config);

        musicStopped = false;
        loadDir = File{ path_directory(fileName) };
        baseName = path_basename(fileName);

        uade_set_amiga_loader(UADEPlayer::amigaloader, this, state);
        auto suffix = path_suffix(fileName);

        if(suffix == "mdat") {
            uadeFile = File::getTempDir() / (suffix + ".music");
            LOGD("Translated %s to %s", fileName, uadeFile.getName());
            uadeFile.copyFrom(File{fileName});
            uadeFile.close();
            fileName = uadeFile.getName();
        }

        currentFileName = fileName;

        if(uade_play(fileName.c_str(), -1, state) == 1) {
            songInfo = uade_get_song_info(state);
            const char* modname = songInfo->modulename;
            if(strcmp(modname, "<no songtitle>") == 0)
                modname = "";
            setMeta(
                "songs", songInfo->subsongs.max - songInfo->subsongs.min + 1,
                "startsong", songInfo->subsongs.def - songInfo->subsongs.min,
                "length", (int)songInfo->duration, "title", modname, "format",
                songInfo->playername);
            valid = true;
        }

        ok = chdir(currDir.c_str());

        return valid;
    }
    ~UADEPlayer() override {
        uade_cleanup_state(state, 1);
        state = nullptr;
        if(uadeFile)
            uadeFile.remove();
    }

    virtual int getSamples(int16_t* target, int noSamples) override {
        ssize_t rc = uade_read(target, noSamples * 2, state);
        struct uade_notification nf;
        while(uade_read_notification(&nf, state)) {
            if(nf.type == UADE_NOTIFICATION_SONG_END) {
                LOGD("UADE SONG END: %d %d %d %s", nf.song_end.happy,
                     nf.song_end.stopnow, nf.song_end.subsong,
                     nf.song_end.reason);
                setMeta("song", nf.song_end.subsong + 1);
                if(nf.song_end.stopnow)
                    musicStopped = true;
            } else if(nf.type == UADE_NOTIFICATION_MESSAGE) {
                LOGD("Amiga message: %s\n", nf.msg);
            } else
                LOGD("Unknown notification: %d\n", nf.type);
            uade_cleanup_notification(&nf);
        }
        if(rc > 0)
            return rc / 2;
        return rc;
    }

    virtual bool seekTo(int song, int seconds) override {
        // if(musicStopped) {
        //	if(uade_play(currentFileName.c_str(), -1, state) == 1) {
        //		songInfo = uade_get_song_info(state);
        //		musicStopped = false;
        //	}
        //}
        uade_seek(UADE_SEEK_SUBSONG_RELATIVE, 0, song + songInfo->subsongs.min,
                  state);
        return true;
    }

private:
    utils::File uadeFile;
    string dataDir;
    bool valid;
    struct uade_state* state;
    const struct uade_song_info* songInfo;
    string baseName;
    string currentFileName;
    utils::File loadDir;
    bool musicStopped;
};

static const set<string> supported_ext{
    "smod",      "lion",         "okta",        "sid",          "ymst",
    "sps",       "spm",          "jb",          "ast",          "ahx",
    "thx",       "adpcm",        "amc",         "nt",           "abk",
    "aam",       "alp",          "aon",         "aon4",         "aon8",
    "adsc",      "mod_adsc4",    "bss",         "bd",           "BDS",
    "uds",       "kris",         "cin",         "core",         "cus",
    "cust",      "custom",       "cm",          "rk",           "rkb",
    "dz",        "mkiio",        "dl",          "dl_deli",      "dln",
    "dh",        "dw",           "dwold",       "dlm2",         "dm2",
    "dlm1",      "dm1",          "dsr",         "db",           "digi",
    "dsc",       "dss",          "dns",         "ems",          "emsv6",
    "ex",        "fc13",         "fc3",         "fc",           "fc14",
    "fc4",       "fred",         "gray",        "bfc",          "bsi",
    "fc-bsi",    "fp",           "fw",          "glue",         "gm",
    "ea",        "mg",           "hd",          "hipc",         "soc",
    "emod",      "qc",           "ims",         "dum",          "is",
    "is20",      "jam",          "jc",          "jmf",          "jcb",
    "jcbo",      "jpn",          "jpnd",        "jp",           "jt",
    "mon_old",   "jo",           "hip",         "mcmd",         "sog",
    "hip7",      "s7g",          "hst",         "kh",           "powt",
    "pt",        "lme",          "mon",         "mfp",          "hn",
    "mtp2",      "thn",          "mc",          "mcr",          "mco",
    "mk2",       "mkii",         "avp",         "mw",           "max",
    "mcmd_org",  "med",          "mmd0",        "mmd1",         "mmd2",
    "mso",       "midi",         "md",          "mmdc",         "dmu",
    "mug",       "dmu2",         "mug2",        "ma",           "mm4",
    "mm8",       "mms",          "ntp",         "two",          "octamed",
    "okt",       "one",          "dat",         "ps",           "snk",
    "pvp",       "pap",          "psa",         "mod_doc",      "mod15",
    "mod15_mst", "mod_ntk",      "mod_ntk1",    "mod_ntk2",     "mod_ntkamp",
    "mod_flt4",  "mod",          "mod_comp",    "!pm!",         "40a",
    "40b",       "41a",          "50a",         "60a",          "61a",
    "ac1",       "ac1d",         "aval",        "chan",         "cp",
    "cplx",      "crb",          "di",          "eu",           "fc-m",
    "fcm",       "ft",           "fuz",         "fuzz",         "gmc",
    "gv",        "hmc",          "hrt",         "hrt!",         "ice",
    "it1",       "kef",          "kef7",        "krs",          "ksm",
    "lax",       "mexxmp",       "mpro",        "np",           "np1",
    "np2",       "noisepacker2", "np3",         "noisepacker3", "nr",
    "nru",       "ntpk",         "p10",         "p21",          "p30",
    "p40a",      "p40b",         "p41a",        "p4x",          "p50a",
    "p5a",       "p5x",          "p60",         "p60a",         "p61",
    "p61a",      "p6x",          "pha",         "pin",          "pm",
    "pm0",       "pm01",         "pm1",         "pm10c",        "pm18a",
    "pm2",       "pm20",         "pm4",         "pm40",         "pmz",
    "polk",      "pp10",         "pp20",        "pp21",         "pp30",
    "ppk",       "pr1",          "pr2",         "prom",         "pru",
    "pru1",      "pru2",         "prun",        "prun1",        "prun2",
    "pwr",       "pyg",          "pygm",        "pygmy",        "skt",
    "skyt",      "snt",          "snt!",        "st2",          "st26",
    "st30",      "star",         "stpk",        "tp",           "tp1",
    "tp2",       "tp3",          "un2",         "unic",         "unic2",
    "wn",        "xan",          "xann",        "zen",          "puma",
    "rjp",       "sng",          "riff",        "rh",           "rho",
    "sa-p",      "scumm",        "s-c",         "scn",          "scr",
    "sid1",      "smn",          "sid2",        "mok",          "sa",
    "sonic",     "sa_old",       "smus",        "snx",          "tiny",
    "spl",       "sc",           "sct",         "psf",          "sfx",
    "sfx13",     "tw",           "sm",          "sm1",          "sm2",
    "sm3",       "smpro",        "bp",          "sndmon",       "bp3",
    "sjs",       "jd",           "doda",        "sas",          "ss",
    "sb",        "jpo",          "jpold",       "sun",          "syn",
    "sdr",       "osp",          "st",          "synmod",       "tfmx1.5",
    "tfhd1.5",   "tfmx7V",       "tfhd7V",      "mdat",         "tfmxpro",
    "tfhdpro",   "tfmx",         "mdst",        "thm",          "tf",
    "tme",       "sg",           "dp",          "trc",          "tro",
    "tronic",    "ufo",          "mod15_ust",   "vss",          "wb",
    "ym",        "ml",           "mod15_st-iv", "agi",          "tpu",
    "qpa",       "sqt",          "qts",         "ftm",          "sdata"};

bool UADEPlugin::canHandle(const std::string& name) {
	auto lowerName = toLower(name);
    if(supported_ext.count(utils::path_extension(lowerName)) > 0)
        return true;
    return (supported_ext.count(utils::path_prefix(lowerName)) > 0);
}


std::vector<std::string> UADEPlugin::getSecondaryFiles(const std::string &file) {
    bool isStarTrekker = (file.find("Startrekker") != string::npos);

    // Known music formats with 2 files
    static const std::unordered_map<string, string> fmt_2files = {
        {"mdat", "smpl"},   // TFMX
        {"sng", "ins"},     // Richard Joseph
        {"jpn", "smp"},     // Jason Page PREFIX
        {"dum", "ins"},     // Rob Hubbard 2
        {"adsc", "adsc.as"}, // Audio Sculpture
        {"sdata", "ip"}, // Audio Sculpture
        {"dns", "smp"} // Dynamic Synthesizer
    };


    string fileName = file;
    string prefix;
    size_t dot = 0;

    string ext = path_extension(file);
    string base = path_basename(file);

    auto slash = file.find_last_of("/\\");
    if(slash != std::string::npos) {
        fileName = file.substr(slash+1);
        dot = fileName.find_first_of('.');
        if(dot != std::string::npos) {
            prefix = fileName.substr(0, dot);
        }
    }
    

    std::vector<std::string> result;

    LOGD("FILENAME '%s', PREFIX '%s', EXT '%s', BASE '%s'", fileName, prefix, ext, base);

    if(fmt_2files.count(prefix) > 0) {
        base = fileName.substr(dot+1);
        LOGD("Found prefix, base now %s", base);
        result.push_back(fmt_2files.at(prefix) + "." + base);
        return result;
    }

    string ext2;
    if(fmt_2files.count(ext) > 0)
        ext2 = fmt_2files.at(ext);
    else if(fmt_2files.count(base) > 0) {
        ext2 = base;
        base = fmt_2files.at(base);
    } else
    if(isStarTrekker)
        ext2 = "mod.nt";
    if(!ext2.empty()) {
        result.push_back(base + "." + ext2);
    }
    return result;
}

ChipPlayer* UADEPlugin::fromFile(const std::string& fileName) {

    auto* player = new UADEPlayer(dataDir + "/uade");
    LOGD("UADE data %s", dataDir);
    if(!player->load(File::resolvePath(fileName))) {
        delete player;
        player = nullptr;
    }
    return player;
};

} // namespace musix
