
#include "UADEPlugin.h"

#include "../../chipplayer.h"

#include <coreutils/utils.h>
#include <coreutils/file.h>
#include <coreutils/log.h>
#include <uade/uade.h>
#include <unistd.h>
#include <set>
#include <unordered_map>
#include <thread>

static std::thread uadeThread;
extern "C" void uade_run_thread(void (*f)(void*), void *data)
{
	LOGD("Starting thread");
	uadeThread = std::thread(f, data);
}

extern "C" void uade_wait_thread()
{
	uadeThread.join();
}

namespace chipmachine {

using namespace std;
using namespace utils;

class UADEPlayer : public ChipPlayer {
public:
	UADEPlayer(const std::string &dataDir) : dataDir(dataDir), valid(false), state(nullptr)  {
	}

	static struct uade_file *amigaloader(const char *name, const char *playerdir, void *context, struct uade_state *state) {
		LOGD("Trying to load '%s' from '%s'", name, playerdir);
		UADEPlayer *up = static_cast<UADEPlayer*>(context);
		string fileName = name;

		if(endsWith(fileName, "SMPL.set"))
			fileName = path_directory(fileName) + "/set.smpl";
		else
		if(path_suffix(fileName) == "music") {
			fileName = path_directory(fileName) + "/" + up->baseName + "." + path_prefix(fileName);
			LOGD("Translated back to '%s'", fileName);
		} else if(up->currentFileName.find(fileName) == 0) {
			LOGD("Restoring filename %s back to '%s'", fileName, up->currentFileName);
			fileName = up->currentFileName;
		}

		struct uade_file *f = uade_load_amiga_file(fileName.c_str(), playerdir, state);
		return f;
	}

	bool load(string fileName) {

		char currdir[2048];
		if(!getcwd(currdir, sizeof(currdir)))
			return false;

		int ok = chdir(dataDir.c_str());

		struct uade_config *config = uade_new_config();
		uade_config_set_option(config, UC_ONE_SUBSONG, NULL);
		uade_config_set_option(config, UC_IGNORE_PLAYER_CHECK, NULL);
		uade_config_set_option(config, UC_NO_EP_END, NULL);
		//uade_config_set_option(config, UC_VERBOSE, "true");
		state = uade_new_state(config);
        free(config);
	
		musicStopped = false;

		uade_set_amiga_loader(UADEPlayer::amigaloader, this, state);
		if(path_suffix(fileName) == "mdat") {
			baseName = path_basename(fileName);
			string uadeFileName = path_directory(fileName) + "/" + path_extension(fileName) + "." + "music";
			LOGD("Translated %s to %s", fileName, uadeFileName);
			File file { uadeFileName };
			File file2 { fileName };
			file.copyFrom(file2);
			file.close();
			fileName = uadeFileName;
		} 

		currentFileName = fileName;

		LOGD("UADEPLAY %s", fileName);

		if(uade_play(fileName.c_str(), -1, state) == 1) {
			songInfo = uade_get_song_info(state);
			const char *modname = songInfo->modulename;
			if(strcmp(modname, "<no songtitle>") == 0)
				modname = "";
			setMeta(
				"songs", songInfo->subsongs.max - songInfo->subsongs.min + 1,
				"startsong", songInfo->subsongs.def - songInfo->subsongs.min,
				"length", songInfo->duration,
				"title", modname,
				"format", songInfo->playername
			);
			//printf("UADE:%s %s\n", songInfo->playerfname, songInfo->playername);
			valid = true;
		}

		ok = chdir(currdir);

		return valid;

	}

	~UADEPlayer() override {
	   uade_cleanup_state(state);
	   state = nullptr;
	}

	virtual int getSamples(int16_t *target, int noSamples) override {
		ssize_t rc = uade_read(target, noSamples*2, state);
		struct uade_notification nf;
		while(uade_read_notification(&nf, state)) {
			if(nf.type == UADE_NOTIFICATION_SONG_END) {
				LOGD("UADE SONG END: %d %d %d %s", nf.song_end.happy, nf.song_end.stopnow, nf.song_end.subsong, nf.song_end.reason);
				setMeta("song", nf.song_end.subsong+1);
				if(nf.song_end.stopnow)
					musicStopped = true;
			} else if(nf.type == UADE_NOTIFICATION_MESSAGE) {
				LOGD("Amiga message: %s\n", nf.msg);
			} else
				LOGD("Unknown notification: %d\n", nf.type);
			uade_cleanup_notification(&nf);
		}
		if(rc > 0)
			return rc/2;
		return rc;
	}

	virtual bool seekTo(int song, int seconds) override {
		//if(musicStopped) {
		//	if(uade_play(currentFileName.c_str(), -1, state) == 1) {
		//		songInfo = uade_get_song_info(state);
		//		musicStopped = false;
		//	}
		//}
		uade_seek(UADE_SEEK_SUBSONG_RELATIVE, 0, song + songInfo->subsongs.min, state);
		return true;	
	}

private:
	string dataDir;
	bool valid;
	struct uade_state *state;
	const struct uade_song_info *songInfo;
	string baseName;
	string currentFileName;
	bool musicStopped;
};

static const set<string> supported_ext {
	"smod", "lion", "okta", "sid", "ymst", "sps", "spm", "jb",
	"ast", "ahx", "thx", "adpcm", "amc", "nt",
	"abk", "aam", "alp", "aon", "aon4", "aon8","adsc", "mod_adsc4", "bss", "bd",
	"BDS", "uds", "kris", "cin", "core", "cus", "cust", "custom", "cm", "rk", "rkb",
	"dz", "mkiio", "dl", "dl_deli", "dln", "dh", "dw", "dwold", "dlm2", "dm2",
	"dlm1", "dm1", "dsr", "db", "digi", "dsc", "dss", "dns", "ems", "emsv6", "ex",
	"fc13", "fc3", "fc", "fc14", "fc4", "fred", "gray", "bfc", "bsi", "fc-bsi",
	"fp", "fw", "glue", "gm", "ea", "mg", "hd", "hipc", "soc", "emod", "qc", "ims",
	"dum", "is", "is20", "jam", "jc", "jmf", "jcb", "jcbo", "jpn", "jpnd", "jp",
	"jt", "mon_old", "jo", "hip", "mcmd", "sog", "hip7", "s7g", "hst", "kh", "powt",
	"pt", "lme", "mon", "mfp", "hn", "mtp2", "thn", "mc", "mcr", "mco", "mk2",
	"mkii", "avp", "mw", "max", "mcmd_org", "med", "mmd0", "mmd1", "mmd2", "mso",
	"midi", "md", "mmdc", "dmu", "mug", "dmu2", "mug2", "ma", "mm4", "mm8", "mms",
	"ntp", "two", "octamed", "okt", "one", "dat", "ps", "snk", "pvp", "pap", "psa",
	"mod_doc", "mod15", "mod15_mst", "mod_ntk", "mod_ntk1", "mod_ntk2",
	"mod_ntkamp", "mod_flt4", "mod", "mod_comp", "!pm!", "40a", "40b", "41a", "50a",
	"60a", "61a", "ac1", "ac1d", "aval", "chan", "cp", "cplx", "crb", "di", "eu",
	"fc-m", "fcm", "ft", "fuz", "fuzz", "gmc", "gv", "hmc", "hrt", "hrt!", "ice",
	"it1", "kef", "kef7", "krs", "ksm", "lax", "mexxmp", "mpro", "np", "np1", "np2",
	"noisepacker2", "np3", "noisepacker3", "nr", "nru", "ntpk", "p10", "p21", "p30",
	"p40a", "p40b", "p41a", "p4x", "p50a", "p5a", "p5x", "p60", "p60a", "p61",
	"p61a", "p6x", "pha", "pin", "pm", "pm0", "pm01", "pm1", "pm10c", "pm18a",
	"pm2", "pm20", "pm4", "pm40", "pmz", "polk", "pp10", "pp20", "pp21", "pp30",
	"ppk", "pr1", "pr2", "prom", "pru", "pru1", "pru2", "prun", "prun1", "prun2",
	"pwr", "pyg", "pygm", "pygmy", "skt", "skyt", "snt", "snt!", "st2", "st26",
	"st30", "star", "stpk", "tp", "tp1", "tp2", "tp3", "un2", "unic", "unic2", "wn",
	"xan", "xann", "zen", "puma", "rjp", "sng", "riff", "rh", "rho", "sa-p",
	"scumm", "s-c", "scn", "scr", "sid1", "smn", "sid2", "mok", "sa", "sonic",
	"sa_old", "smus", "snx", "tiny", "spl", "sc", "sct", "psf", "sfx", "sfx13",
	"tw", "sm", "sm1", "sm2", "sm3", "smpro", "bp", "sndmon", "bp3", "sjs", "jd",
	"doda", "sas", "ss", "sb", "jpo", "jpold", "sun", "syn", "sdr", "osp", "st",
	"synmod", "tfmx1.5", "tfhd1.5", "tfmx7V", "tfhd7V", "mdat", "tfmxpro",
	"tfhdpro", "tfmx", "mdst", "thm", "tf", "tme", "sg", "dp", "trc", "tro",
	"tronic", "ufo", "mod15_ust", "vss", "wb", "ym", "ml", "mod15_st-iv", "agi",
	"tpu", "qpa", "sqt", "qts"
}; 


bool UADEPlugin::canHandle(const std::string&name) {  
	return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *UADEPlugin::fromFile(const std::string &fileName) {


	auto *player = new UADEPlayer(dataDir + "/data/uade");
	LOGD("UADE data %s", dataDir);
	if(!player->load(File::resolvePath(fileName))) {
		delete player;
		player = nullptr;
	}
	return player;
};

}
