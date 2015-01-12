
extern "C" {
#include "archdep.h"
#include "drive.h"
#include "gfxoutput.h"
#include "init.h"
#include "initcmdline.h"
#include "lib.h"
#include "machine.h"
#include "maincpu.h"
#include "psid.h"
#include "resources.h"
#include "sound.h"
#include "sysfile.h"
#include "sid/sid.h"


void psid_play(short *buf, int size);
const char *psid_get_name();
const char *psid_get_author();
const char *psid_get_copyright();
int psid_tunes(int* default_tune);

}

#include "VicePlugin.h"
#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/utils.h>
#include <coreutils/file.h>
#include <crypto/md5.h>

#include <set>
#include <algorithm>

int console_mode = 1;
int vsid_mode = 1;
int video_disabled_mode = 1;

namespace chipmachine {

using namespace std;
using namespace utils;


static bool videomode_is_ntsc = false;
static bool videomode_is_forced = false;
static int sid = 3;//SID_MODEL_DEFAULT;// SID_MODEL_8580;
static bool sid_is_forced = true;

 template <typename T> const T get(const vector<uint8_t> &v, int offset) {}

template <> const uint16_t get(const vector<uint8_t> &v, int offset) {
	return (v[offset] <<8) | v[offset+1];
}

template <> const uint32_t get(const vector<uint8_t> &v, int offset) {
	return (v[offset] <<24) | (v[offset+1]<<16) | (v[offset+2] <<8) | v[offset+3];
}

enum {
	MAGICID = 0,
	PSID_VERSION = 4,
	DATA_OFFSET = 6,
	LOAD_ADDRESS  = 8,
	INIT_ADDRESS = 0xA,
	PLAY_ADDRESS = 0xC,
	SONGS = 0xE,
	START_SONG = 0x10,
	SPEED = 0x12,
	FLAGS = 0x76
};

class VicePlayer : public ChipPlayer {
public:

	vector<uint8_t> calculateMD5(vector<uint8_t> data) {
		
		uint8_t speed = (data[0] == 'R') ? 60 : 0;
		uint16_t version = get<uint16_t>(data, PSID_VERSION);

		uint16_t initAdr = get<uint16_t>(data, INIT_ADDRESS);
		uint16_t playAdr = get<uint16_t>(data, PLAY_ADDRESS);
		uint16_t songs = get<uint16_t>(data, SONGS);

		uint32_t speedBits = get<uint32_t>(data, SPEED);
		uint16_t flags = get<uint16_t>(data, FLAGS);

		MD5 md5;

		auto offset = (version == 2) ? 126 : 120;

		md5.add(data, offset);

		md5.add(initAdr);
		md5.add(playAdr);
		md5.add(songs);	

		for(int i=0; i<songs; i++) {
			if((speedBits & (1 << i)) != 0) {
				md5.add((uint8_t)60);
			} else {
				md5.add(speed);
			}
		}

		if((flags & 0x8) != 0) {
			md5.add((uint8_t)2);
		}

		return md5.get();
	}

	static bool init(const string &c64Dir) {
		maincpu_early_init();
		machine_setup_context();
		drive_setup_context();
		machine_early_init();
		sysfile_init("C64");
		gfxoutput_early_init();
		if(init_resources() < 0) {
			archdep_startup_log_error("Failed to init resources");
			return false;
		}

		if(resources_set_defaults() < 0) {
			archdep_startup_log_error("Cannot set defaults.\n");
			return false;
		}

		resources_set_int("SidResidSampling", 0);
		resources_set_int("VICIIVideoCache", 0);
		resources_set_string("Directory", c64Dir.c_str());
		if(init_main() < 0) {
			archdep_startup_log_error("Failed to init main");
			return false;
		}

		return true;
	}

	static void c64_song_init()
	{
		/* Set default, potentially overridden by reset. */
		resources_set_int("MachineVideoStandard", videomode_is_ntsc ? MACHINE_SYNC_NTSC : MACHINE_SYNC_PAL);
		
		/* Default to 6581 in case tune doesn't specify. */
		resources_set_int("SidModel", sid);

		/* Reset C64, which also initializes PSID for us. */
		machine_trigger_reset(MACHINE_RESET_MODE_SOFT);

		/* Now force video mode if we are asked to. */
		if (videomode_is_forced)
		{
			resources_set_int("MachineVideoStandard", videomode_is_ntsc ? MACHINE_SYNC_NTSC : MACHINE_SYNC_PAL);
		}
		
		/* Force the SID model if told to in the settings */
		if (sid_is_forced)
		{
			resources_set_int("SidModel", sid);
		}

	}

	VicePlayer(const string &sidFile) {
		int ret = psid_load_file(sidFile.c_str());
		LOGD("Loaded %s -> %d", sidFile, ret);
		if (ret == 0) {

			File f { sidFile };
			auto data = f.getData();
			auto md5 = calculateMD5(data);
			uint32_t key = get<uint32_t>(md5, 0);
			LOGD("MD5: [%02x] %08x", md5, key);
			songLengths = VicePlugin::findLengths(key);

			string realPath = sidFile;
			if(sidFile.find("C64Music%2f") != string::npos) {
				realPath = utils::urldecode(sidFile, ":/\\?;");
			}

			int defaultSong;
			int songs = psid_tunes(&defaultSong);
			defaultSong--;
			currentSong = defaultSong;
			LOGD("DEFSONG: %d", defaultSong);
			currentLength = 0;
			currentPos = 0;
			nextCheckPos = currentPos + 44100;
			if((int)songLengths.size() > defaultSong) {
				currentLength = songLengths[defaultSong];
			}
			LOGD("Length:%d", currentLength);
			string msg = "NO STIL INFO";
			string sub_title;
			auto pos = realPath.find("C64Music/");
			currentInfo = 0;
			if(pos != string::npos) {
				auto p = realPath.substr(pos+8);
				LOGD("SIDFILE:%s", p);
				if(VicePlugin::stilSongs.count(p)) {
					currentStil = VicePlugin::stilSongs[p];
					msg = currentStil.comment;

					for(int i=0; i<(int)currentStil.songs.size(); i++) {
						auto &s = currentStil.songs[i];
						LOGD("#%d: %s", s.subsong, s.title);
						if(s.subsong == defaultSong+1) {
							currentInfo = i;
							sub_title = s.title;//sub_title + s.title + " ";
							if(sub_title == "") sub_title = s.name;

							if(msg == "") msg = s.comment;
							break;
						}
					}
				}
			}
			setMeta(
				"title", psid_get_name(),
				"composer", psid_get_author(),
				"copyright", psid_get_copyright(),
				"format", "C64 Sid",
				"songs", songs,
				"message", msg,
				"sub_title", sub_title,
				"length", currentLength,
				"startSong", defaultSong
			);

			c64_song_init();
		}
	}

	~VicePlayer() {
		psid_set_tune(-1);
	}

	virtual bool seekTo(int song, int seconds = -1) {
		if(song >= 0) {
			currentSong = song;
			psid_set_tune(song+1);
			c64_song_init();
			currentLength = 0;
			currentPos = 0;
			if((int)songLengths.size() > song) {
				currentLength = songLengths[song];
			}

			LOGD("Length:%d, SONG %d", currentLength, song);
			string sub_title;
			string msg = currentStil.comment;
			for(int i=0; i<(int)currentStil.songs.size(); i++) {
				auto &s = currentStil.songs[i];
				LOGD("#%d: %s", s.subsong, s.title);
				if(s.subsong == song+1) {
					currentInfo = i;
					sub_title = s.title; //sub_title + s.title + " ";
					if(sub_title == "") sub_title = s.name;
					if(s.comment != "") msg = s.comment;
					break;
				}
			}

			setMeta("length", currentLength, "sub_title", sub_title, "message", msg);
			return true;
		}
		return false;
	}

	virtual int getSamples(int16_t *target, int size) {
		currentPos += (size/2);

		if(currentPos > nextCheckPos) {
			int sec = currentPos / 44100;
			nextCheckPos = currentPos + 44100;
			for(int i=currentInfo+1; i<(int)currentStil.songs.size(); i++) {
				auto &s = currentStil.songs[i];
				if(s.subsong == currentSong+1) {
					if(s.seconds > 0 && sec >= s.seconds) {
						LOGD("Found new info");
						currentInfo = i;
						if(s.comment != "")
							setMeta("sub_title", s.title, "message", s.comment);
						else
							setMeta("sub_title", s.title);
						break;
					}
				}


			}
		}

		//LOGD("%d vs %d", currentPos, currentLength*44100);
		//if(currentLength > 0 && currentPos > currentLength*44100)
		//	return -1;
		psid_play(target, size);
		return size;
	}
	uint32_t currentLength;
	uint32_t currentPos;
	uint32_t nextCheckPos;
	int currentInfo;
	int currentSong;
	std::vector<uint16_t> songLengths;

	VicePlugin::STILSong currentStil;
};

VicePlugin::VicePlugin(const string &dataDir) {
	VicePlayer::init(dataDir.c_str());
	readLengths();
	readSTIL();
}

VicePlugin::VicePlugin(const unsigned char *data) {
	mkdir("c64", 0777);

	FILE *fp;
	fp = fopen("c64/basic", "wb");
	fwrite(&data[0], 1, 8192, fp);
	fclose(fp);

	fp = fopen("c64/chargen", "wb");
	fwrite(&data[8192], 1, 4096, fp);
	fclose(fp);

	fp = fopen("c64/kernal", "wb");
	fwrite(&data[8192+4096], 1, 8192, fp);
	fclose(fp);
	VicePlayer::init("c64");

	readLengths();
}

static File find_file(const std::string &name) {
	return File::findFile(current_exe_path() + ":" + File::getAppDir(), name);
}

void VicePlugin::readSTIL() {

	STIL current;
	vector<STIL> songs;
	File f = find_file("data/STIL.txt");
	//int subsong = -1;
	string path;
	string what;
	string content;
	string songComment;
	bool currentSet = false;
	//int seconds = 0;
	//int count = 0;
	for(auto l : f.getLines()) {
		//LOGD("'%c' : %s", l[0], l);
		if(l == "" || l[0] == '#')
			continue;
		//if(count++ == 300) break;
		if(l.length() > 4 && l[4] == ' ' && what != "") {
			content = content + " " + lstrip(l);
		} else {
			if(what != "" && content != "") {
				if(songComment == "" && what == "COMMENT" && songs.size() == 0 && current.title == "" && current.name == "") {
					songComment = content;
				} else {
					//LOGD("WHAT:%s = '%s'", what, content);
					if(what == "TITLE")
						current.title = content;
					else if(what == "COMMENT")
						current.comment = content;
					else if(what == "AUTHOR")
						current.author = content;
					else if(what == "ARTIST")
						current.artist = content;
					else if(what == "NAME")
						current.name = content;
					currentSet = true;
				}
				what = "";
				content = "";
			}


			if(l[0] == '/') {
				if(currentSet) {
					songs.push_back(current);
					current = STIL();
					currentSet = false;
					//LOGD("PATH:%s", path);
					//LOGD("========================================");
					//for(auto &s : songs) {
					//	LOGD(" (#%d) T:%s BY:%s A:%s C:%s SEC:%d", s.subsong, s.title, s.artist, s.author, s.comment, s.seconds);
					//}
				}
				//LOGD("Adding '%s'", path);
				stilSongs[path] = STILSong(songs, songComment);
				songComment = "";
				songs.clear();
				path = l;
				current.subsong = 1;
				current.seconds = 0;
				what = "";
				content = "";
			} else if(l[0] == '(') {

				if(currentSet) {
					if(songComment == "" && current.comment != "" && songs.size() == 0 && current.title == "" && current.name == "") {
						songComment = content;
					} else {
						songs.push_back(current);
					}
					current = STIL();
					currentSet = false;
				}
				current.subsong = atoi(l.substr(2).c_str());
				//LOGD("SUBSONG %d", current.subsong);
				current.seconds = 0;
				content = "";
				what = "";
			} else {
				auto colon = l.find(":");
				if(colon != string::npos) {
					what = lstrip(l.substr(0,colon));
					content = l.substr(colon+1);
					if(what == "TITLE") {
						if(currentSet && current.title != "") {
							songs.push_back(current);
							auto s = current.subsong;
							current = STIL();
							current.subsong = s;
							currentSet = false;
						}
						if(content[content.size()-1] == ')') {
							auto pos = content.rfind("(");
							auto secs = split(content.substr(pos+1), ":");
							if(secs.size() >= 2) {
								int m = atoi(secs[0].c_str());
								int s = atoi(secs[1].c_str());
								current.seconds = s + m * 60;
							}					
						}
					}
				}
			}
		}
	}
}

void VicePlugin::readLengths() {

	File f = find_file("data/songlengths.dat");

	if(f.exists()) {
		auto data = f.getData();

		auto len = get<uint32_t>(data, 0);
		LOGD("Found %d songs in songlengths.dat", len);

		mainHash.resize(6*len);
		memcpy(&mainHash[0], &data[4], 6*len);

		auto offs = 4 + 6*len;
		auto elen = (data.size() - offs) / 2;

		extraLengths.resize(elen*2);
		for(int i=0; i<(int)elen; i++)
			extraLengths[i] = get<uint16_t>(data, offs+i*2);
	}
}

VicePlugin::~VicePlugin() {
	LOGD("VicePlugin destroy\n");
	machine_shutdown();
}

static const set<string> ext { ".sid", ".psid", ".rsid" , ".2sid", ".mus" };

bool VicePlugin::canHandle(const std::string &name) {
	for(string x : ext) {
		if(utils::endsWith(name, x))
			return true;
	}
	return false;
}

ChipPlayer *VicePlugin::fromFile(const std::string &fileName) {
	return new VicePlayer { fileName };
}

vector<uint8_t> VicePlugin::mainHash;
vector<uint16_t> VicePlugin::extraLengths;
unordered_map<string, VicePlugin::STILSong> VicePlugin::stilSongs;

vector<uint16_t> VicePlugin::findLengths(uint32_t key) {

	vector<uint16_t> songLengths;
	//long key = ((md5[0]&0xff) << 24) | ((md5[1]&0xff) << 16) | ((md5[2]&0xff) << 8) | (md5[3] & 0xff);
	//key &= 0xffffffffL;

	int first = 0;
	int upto = mainHash.size() / 6;
	//int found = -1;
	

	//short lens [] = new short [128];
	
	//Log.d(TAG, "MD5 %08x", key);
	while (first < upto) {
		int mid = (first + upto) / 2;  // Compute mid point.

		uint32_t hash = get<uint32_t>(mainHash, mid*6);
		//long hash = ((mainHash[mid*6]&0xff) << 24) | ((mainHash[mid*6+1]&0xff) << 16) | ((mainHash[mid*6+2]&0xff) << 8) | (mainHash[mid*6+3] & 0xff);
		//hash &= 0xffffffffL;

		//Log.d(TAG, "offs %x, hash %08x", mid, hash);
		if (key < hash) {
			upto = mid;     // repeat search in bottom half.
		} else if (key > hash) {
			first = mid + 1;  // Repeat search in top half.
		} else {
			//found = mid;
			//int len = ((mainHash[mid*6+4]&0xff)<<8) | (mainHash[mid*6+5]&0xff);
			uint16_t len = get<uint16_t>(mainHash, mid*6+4);
			LOGD("LEN: %x", len);
			if((len & 0x8000) != 0) {
				len &= 0x7fff;
				int xl = 0;
				while((xl & 0x8000) == 0) {
					xl = extraLengths[len++];
					songLengths.push_back(xl & 0x7fff);
				}
				
				//for(int i=0; i<n; i++) {
				//	Log.d(TAG, "LEN: %02d:%02d", songLengths[i]/60, songLengths[i]%60);
				//}
			} else {
				LOGD("SINGLE LEN: %02d:%02d", len/60, len%60);
				songLengths.push_back(len);
			}
			break;
		}
	}
	return songLengths;
}

}