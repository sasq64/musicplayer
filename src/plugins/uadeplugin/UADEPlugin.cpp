
#include "UADEPlugin.h"

#include "../../chipplayer.h"

#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <uade/uade.h>

#include <filesystem>
#include <set>
#include <thread>
#include <unordered_map>

namespace fs = std::filesystem;

static std::thread uadeThread;
extern "C" void uade_run_thread(void (*f)(void*), void* data)
{
    LOGD("Starting thread");
    uadeThread = std::thread(f, data);
}

extern "C" void uade_wait_thread()
{
    uadeThread.join();
}

namespace musix {

class UADEPlayer : public ChipPlayer
{
public:
    explicit UADEPlayer(const fs::path& _dataDir) : dataDir(_dataDir) {}

    // Called when Amiga wants to load a file
    static struct uade_file* amigaloader(const char* name,
                                         const char* playerdir, void* context,
                                         struct uade_state* state)
    {
        LOGD("Trying to load '{}' from '{}'", name, playerdir);
        auto* player = static_cast<UADEPlayer*>(context);

        fs::path fileName = name;

        auto ext = fileName.extension();

        if (utils::startsWith(name, "Env:")) {
            fileName = fs::path(playerdir) / "ENV" / &name[4];
        } else if (utils::startsWith(name, "smpl.")) {
            fileName = player->loadDir / (player->baseName + ".smpl");
        } else if (utils::endsWith(fileName.string(), "SMPL.set")) {
            fileName = player->loadDir / "set.smpl";
        } else if (!player->uadeFile.empty()) {
            fileName = player->loadDir /
                       (player->baseName + "." + utils::path_prefix(fileName));
            LOGD("Translated back to '{}'", fileName.string());
        } else if (player->currentFileName.string().find(fileName.string()) ==
                   0) {
            LOGD("Restoring filename {} back to '{}'", fileName.string(),
                 player->currentFileName.string());
            fileName = player->currentFileName;
        }

        LOGD("Actually loading {}", fileName.string());
        struct uade_file* f =
            uade_load_amiga_file(fileName.string().c_str(), playerdir, state);
        return f;
    }

    bool load(fs::path const& fileName)
    {
        struct uade_config* config = uade_new_config();
        uade_config_set_option(config, UC_ONE_SUBSONG, nullptr);
        uade_config_set_option(config, UC_IGNORE_PLAYER_CHECK, nullptr);
        uade_config_set_option(config, UC_NO_EP_END, nullptr);
        // uade_config_set_option(config, UC_VERBOSE, "true");
        uade_config_set_option(config, UC_BASE_DIR,
                               fs::absolute(dataDir).string().c_str());
        state = uade_new_state(config, 1);
        free(config);

        loadDir = fileName.parent_path();
        baseName = fileName.stem().string();
        currentFileName = fileName;

        uade_set_amiga_loader(UADEPlayer::amigaloader, this, state);
        auto suffix = fileName.extension();

        if (suffix == ".mdat") {
            // Transform to prefixed name so UADE can recognize it
            uadeFile = utils::getTempDir() / "mdat.music";
            LOGD("Translated {} to {}", fileName.string(), uadeFile.string());
            if (fs::exists(uadeFile)) { fs::remove(uadeFile); }
            fs::copy(fileName, uadeFile);
            currentFileName = uadeFile;
        }

        LOGD("UADE FILE {}", currentFileName.string());
        if (uade_play(currentFileName.string().c_str(), -1, state) == 1) {
            songInfo = uade_get_song_info(state);
            std::string modname = songInfo->modulename;
            if (modname == "<no songtitle>") { modname = ""; }
            if (modname.empty()) {
                fs::path p = currentFileName;
                auto stem = p.stem().string();
                auto file_name = p.filename().string();
                if (utils::startsWith(file_name, "mdat")) {
                    modname = file_name.substr(5);
                } else {
                    modname = stem;
                }
            }
            setMeta("songs",
                    songInfo->subsongs.max - songInfo->subsongs.min + 1,
                    "startsong",
                    songInfo->subsongs.def - songInfo->subsongs.min, "length",
                    static_cast<uint32_t>(songInfo->duration), "title", modname,
                    "format", std::string(songInfo->playername) + " (Amiga)");
            valid = true;
        }
        return valid;
    }
    ~UADEPlayer() override
    {
        uade_cleanup_state(state, 1);
        state = nullptr;
        if (!uadeFile.empty()) { fs::remove(uadeFile); }
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        auto rc = uade_read(target, noSamples * 2, state);
        struct uade_notification nf
        {};
        while (uade_read_notification(&nf, state) != 0) {
            if (nf.type == UADE_NOTIFICATION_SONG_END) {
                LOGD("UADE SONG END: {} {} {} {}", nf.song_end.happy,
                     nf.song_end.stopnow, nf.song_end.subsong,
                     nf.song_end.reason);
                setMeta("song", nf.song_end.subsong + 1);
                // if (nf.song_end.stopnow)
                //  musicStopped = true;
                return 0;
            }
            if (nf.type == UADE_NOTIFICATION_MESSAGE) {
                LOGD("Amiga message: {}\n", nf.msg);
            } else {
                LOGD("Unknown notification: {}\n", nf.type);
            }
            uade_cleanup_notification(&nf);
        }
        if (rc > 0) { return rc / 2; }
        return rc;
    }

    bool seekTo(int song, int /*seconds*/) override
    {
        if (song < 0) { return false; }
        uade_seek(UADE_SEEK_SUBSONG_RELATIVE, 0, song + songInfo->subsongs.min,
                  state);
        setMeta("song", song);
        return true;
    }

private:
    fs::path uadeFile; // Copy of main song but with different name
    fs::path dataDir;
    bool valid{false};
    struct uade_state* state{};
    const struct uade_song_info* songInfo{};
    std::string baseName;
    fs::path currentFileName;
    fs::path loadDir;
};

static const std::set<std::string> supported_ext{
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
    "qpa",       "sqt",          "qts",         "ftm",          "sdata",
    "dux"};

bool UADEPlugin::canHandle(const std::string& name)
{
    auto lowerName = utils::toLower(name);
    if (supported_ext.count(utils::path_extension(lowerName)) > 0) {
        return true;
    }
    return (supported_ext.count(utils::path_prefix(lowerName)) > 0);
}

std::vector<std::string> UADEPlugin::getSecondaryFiles(const std::string& file)
{
    bool isStarTrekker = (file.find("Startrekker") != std::string::npos);

    // Known music formats with 2 files
    static const std::unordered_map<std::string, std::string> fmt_2files = {
        {"mdat", "smpl"},    // TFMX
        {"sng", "ins"},      // Richard Joseph
        {"jpn", "smp"},      // Jason Page PREFIX
        {"dum", "ins"},      // Rob Hubbard 2
        {"adsc", "adsc.as"}, // Audio Sculpture
        {"sdata", "ip"},     // Audio Sculpture
        {"dns", "smp"}       // Dynamic Synthesizer
    };

    std::string fileName = file;
    std::string prefix;
    size_t dot = 0;

    std::string ext = utils::path_extension(file);
    std::string base = utils::path_basename(file);

    auto slash = file.find_last_of("/\\");
    if (slash != std::string::npos) {
        fileName = file.substr(slash + 1);
        dot = fileName.find_first_of('.');
        if (dot != std::string::npos) { prefix = fileName.substr(0, dot); }
    }

    std::vector<std::string> result;

    LOGD("FILENAME '{}', PREFIX '{}', EXT '{}', BASE '{}'", fileName, prefix,
         ext, base);

    if (fmt_2files.count(prefix) > 0) {
        base = fileName.substr(dot + 1);
        LOGD("Found prefix, base now {}", base);
        result.push_back(fmt_2files.at(prefix) + "." + base);
        return result;
    }

    std::string ext2;
    if (fmt_2files.count(ext) > 0) {
        ext2 = fmt_2files.at(ext);
    } else if (fmt_2files.count(base) > 0) {
        ext2 = base;
        base = fmt_2files.at(base);
    } else if (isStarTrekker) {
        ext2 = "mod.nt";
    }
    if (!ext2.empty()) { result.push_back(base + "." + ext2); }
    return result;
}

ChipPlayer* UADEPlugin::fromFile(const std::string& fileName)
{
    auto realName = fs::absolute(fileName);
    auto* player = new UADEPlayer(dataDir / "uade");
    LOGD("UADE data {}", dataDir.string());
    if (!player->load(realName)) {
        delete player;
        player = nullptr;
    }
    return player;
}

} // namespace musix
