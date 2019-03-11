
#include "AdPlugin.h"

#include "../../chipplayer.h"
#include <cmath>
#include "adplug/adplug.h"
#include "adplug/emuopl.h"
#include "libbinio/binfile.h"
#include "libbinio/binio.h"
#include "opl/dbemuopl.h"

#include <coreutils/utils.h>
#include <coreutils/log.h>

#include <cstdio>
#include <set>
#include <string>
#include <unordered_map>

using namespace std;

namespace musix {

class AdPlugPlayer : public ChipPlayer {

    Copl *emu;
    CPlayer *m_player = nullptr;
    /* STATIC! */ CAdPlugDatabase *g_database = nullptr;

public:
    AdPlugPlayer(const std::string &fileName, const std::string &configDir) {

        if(!g_database) {
            binistream *fp = new binifstream(configDir + "/" + "adplug.db");
            fp->setFlag(binio::BigEndian, false);
            fp->setFlag(binio::FloatIEEE);

            g_database = new CAdPlugDatabase();
            g_database->load(*fp);
            delete fp;
            CAdPlug::set_database(g_database);
        }

        emu = new CEmuopl(44100, true, true);

        m_player = CAdPlug::factory(fileName.c_str(), emu, CAdPlug::players);

        if(!m_player)
            throw player_exception();

        setMeta("title", m_player->gettitle(), "composer",
                m_player->getauthor(), "length", m_player->songlength() / 1000,
                "songs", m_player->getsubsongs(), "format",
                m_player->gettype());
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

        int freq = 44100; // 49716;

        static long minicnt = 0;
        long i, towrite = noSamples / 2;
        auto *pos = target;

        while(towrite > 0) {
            while(minicnt < 0) {
                minicnt += freq;
                auto playing = m_player->update();
                if(!playing)
                    return -1;
            }
            i = min(towrite, (long)(minicnt / m_player->getrefresh() + 4) & ~3);
            emu->update(pos, i);
            pos += i * 2;
            towrite -= i;
            minicnt -= (long)(m_player->getrefresh() * i);
        }

        return noSamples;
    }
};

static const set<string> supported_ext{
    "a2m", "adl", "amd", "bam",  "cff", "cmf", "d00", "dfm",
    "dmo", "dro", "dtm", "hcs",  "hsp", "imf", "ksm", "laa",
    "lds", "m",   "mad", "mid",  "mkj", "msc", "mtk", "rad",
    "raw", "rix", "rol", "as3m", "sa2", "sat", "sci", /*"sng", */ "xad",
    "xms", "xsm", "hsc", "edl",  "mtr", "adlib" };

bool AdPlugin::canHandle(const std::string &name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *AdPlugin::fromFile(const std::string &fileName) {
    try {
        return new AdPlugPlayer{fileName, configDir};
    } catch(player_exception&) {
        return nullptr;
    }
};

} // namespace musix
