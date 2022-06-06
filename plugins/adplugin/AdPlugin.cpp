
#include "AdPlugin.h"

#include "../../chipplayer.h"
#include "adplug/adplug.h"
#include "adplug/emuopl.h"
#include "libbinio/binfile.h"
#include "libbinio/binio.h"

#include <math.h>

#include "opl/dbemuopl.h"

#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <cmath>
#include <cstdio>
#include <set>
#include <string>
#include <unordered_map>

#ifdef min
#    undef min
#endif

namespace musix {

class AdPlugPlayer : public ChipPlayer
{

    Copl* emu;
    CPlayer* m_player = nullptr;
    /* STATIC! */ CAdPlugDatabase* g_database = nullptr;

public:
    AdPlugPlayer(const std::string& fileName, const std::string& configDir)
    {

        if (g_database == nullptr) {
            binistream* fp = new binifstream(configDir + "/" + "adplug.db");
            fp->setFlag(binio::BigEndian, false);
            fp->setFlag(binio::FloatIEEE);

            g_database = new CAdPlugDatabase();
            g_database->load(*fp);
            delete fp;
            CAdPlug::set_database(g_database);
        }

        emu = new CEmuopl(44100, true, true);

        m_player = CAdPlug::factory(fileName, emu, CAdPlug::players);

        if (m_player == nullptr) { throw player_exception(); }

        setMeta("title", m_player->gettitle(), "composer",
                m_player->getauthor(), "length", m_player->songlength() / 1000,
                "songs", m_player->getsubsongs(), "format",
                m_player->gettype());
    }

    ~AdPlugPlayer() override
    {
        delete m_player;
        delete emu;
        emu = nullptr;
        m_player = nullptr;
    }

    int getSamples(int16_t* target, int noSamples) override
    {

        int freq = 44100; // 49716;

        static long minicnt = 0;
        long i = 0;
        long towrite = noSamples / 2;
        auto* pos = target;

        while (towrite > 0) {
            while (minicnt < 0) {
                minicnt += freq;
                auto playing = m_player->update();
                if (!playing) { return -1; }
            }
            i = std::min(towrite,
                         (long)(minicnt / m_player->getrefresh() + 4) & ~3);
            emu->update(pos, i);
            pos += i * 2;
            towrite -= i;
            minicnt -= (long)(m_player->getrefresh() * i);
        }

        return noSamples;
    }
};

static const std::set<std::string> supported_ext{
    "a2m",  "adl", "amd", "bam",   "cff", "cmf", "d00", "dfm", "dmo",
    "dro",  "dtm", "hcs", "hsp",   "imf", "ksm", "laa", "lds", "m",
    "mad",  "mid", "mkj", "msc",   "mtk", "rad", "raw", "rix", "rol",
    "as3m", "sa2", "sat", "sci",   "agd", "sdb", "xad", "xms", "xsm",
    "hsc",  "edl", "mtr", "adlib", "sqx"};

bool AdPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* AdPlugin::fromFile(const std::string& fileName)
{
    return new AdPlugPlayer{fileName, configDir};
};

} // namespace musix
