
#include "AdPlugin.h"

#include <string>
#include <stdio.h>
#include <math.h>


#include "adplug/emuopl.h"
#include "adplug/kemuopl.h"
#include "opl/dbemuopl.h"
#include "adplug/temuopl.h"
#include "adplug/adplug.h"
#include "libbinio/binfile.h"
#include "libbinio/binio.h"
#include "../../chipplayer.h"

#include <coreutils/utils.h>
#include <set>
#include <unordered_map>

extern "C" {
}

using namespace std;

namespace chipmachine {

#define INFO_TITLE 0
#define INFO_AUTHOR 1
#define INFO_LENGTH 2
#define INFO_TYPE 3
#define INFO_COPYRIGHT 4
#define INFO_GAME 5
#define INFO_SUBTUNES 6
#define INFO_STARTTUNE 7 

#define INFO_INSTRUMENTS 100
#define INFO_CHANNELS 101
#define INFO_PATTERNS 102  


class AdPlugPlayer : public ChipPlayer {

	Copl *emu;
	CPlayer * m_player = nullptr;
	/* STATIC! */ CAdPlugDatabase * g_database = nullptr; 
public:
	AdPlugPlayer(const std::string &fileName) {

		int core = 0;
			
		if(!g_database) {
			binistream *fp  = new binifstream("data/adplug.db");
			fp->setFlag(binio::BigEndian, false);
			fp->setFlag(binio::FloatIEEE);
				
			g_database = new CAdPlugDatabase();
			g_database->load( *fp );
			delete fp;
			CAdPlug::set_database( g_database );
		}

		int emuhz = 44100;//49716;				

		switch (core) {
		case 2:
			emu = new CEmuopl( emuhz, true, true );
			break;
		case 1:
			emu = new CKemuopl( emuhz, true, true );
			break;
		case 0:
			emu = new DBemuopl( emuhz, true );
			break;
		}

		m_player = CAdPlug::factory(fileName.c_str(), emu, CAdPlug::players );

		if(!m_player)
			throw player_exception();

		setMeta(
			"title", m_player->gettitle(),
			"composer", m_player->getauthor(),
			"length", m_player->songlength() / 1000,
			"songs", m_player->getsubsongs(),
			"format", m_player->gettype()
		);

		LOGD("CORE %d, PLAYER %p", core, m_player);
	}

	~AdPlugPlayer() {

		if(m_player)
			delete m_player;
		if(emu)
			delete emu;
		emu = nullptr;
		m_player = nullptr;
	}

	virtual int getSamples(int16_t *target, int noSamples) override {

		int freq = 44100;//49716;

		static long minicnt = 0;
		long i, towrite = noSamples/2;
		auto *pos = target;

		while(towrite > 0) {
			while(minicnt < 0) {
				minicnt += freq;
				auto playing = m_player->update();
				if(!playing) return -1;
			}
			i = min(towrite, (long)(minicnt / m_player->getrefresh() + 4) & ~3);
			emu->update(pos, i);
			pos += i * 2; towrite -= i;
			minicnt -= (long)(m_player->getrefresh() * i);
		}

		return noSamples;

	}
};

static const set<string> supported_ext {
		"a2m", "adl", "amd", "bam", "cff", "cmf", "d00", "dfm", "dmo", "dro", "dtm", 
		"hcs", "hsp", "imf", "ksm", "laa", "lds", "m",   "mad", "mid", "mkj", 
		"msc", "mtk", "rad", "raw", "rix", "rol", "as3m", "sa2", "sat", "sci", 
		/*"sng", */ "xad", "xms", "xsm", "hsc", "edl" };

bool AdPlugin::canHandle(const std::string &name) {
	return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *AdPlugin::fromFile(const std::string &fileName) {
	try {
		return new AdPlugPlayer { fileName };
	} catch(player_exception &e) {
		return nullptr;
	}
};

}
