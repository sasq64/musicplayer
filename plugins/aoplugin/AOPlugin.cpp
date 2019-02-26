
#include "AOPlugin.h"
#include "../../chipplayer.h"

#include <coreutils/file.h>
#include <coreutils/utils.h>
#include <coreutils/log.h>
#include <coreutils/split.h>

#include <set>
#include <string>

extern "C" {
#include "ao.h"
int32 ssf_start(uint8 *, uint32 length);
int32 ssf_gen(int16 *, uint32);
int32 ssf_stop(void);
int32 ssf_command(int32, int32);
int32 ssf_fill_info(ao_display_info *);

int32 qsf_start(uint8 *, uint32 length);
int32 qsf_gen(int16 *, uint32);
int32 qsf_stop(void);
int32 qsf_command(int32, int32);
int32 qsf_fill_info(ao_display_info *);

int32 spu_start(uint8 *, uint32 length);
int32 spu_gen(int16 *, uint32);
int32 spu_stop(void);
int32 spu_command(int32, int32);
int32 spu_fill_info(ao_display_info *);

uint8 qsf_memory_read(uint16 addr);
uint8 qsf_memory_readop(uint16 addr);
uint8 qsf_memory_readport(uint16 addr);
void qsf_memory_write(uint16 addr, uint8 byte);
void qsf_memory_writeport(uint16 addr, uint8 byte);

/* redirect stubs to interface the Z80 core to the QSF engine */
uint8 memory_read(uint16 addr) {
    return qsf_memory_read(addr);
}

uint8 memory_readop(uint16 addr) {
    return memory_read(addr);
}

uint8 memory_readport(uint16 addr) {
    return qsf_memory_readport(addr);
}

void memory_write(uint16 addr, uint8 byte) {
    qsf_memory_write(addr, byte);
}

void memory_writeport(uint16 addr, uint8 byte) {
    qsf_memory_writeport(addr, byte);
}

static std::string baseDir;

/* ao_get_lib: called to load secondary files */
int ao_get_lib(char *filename, uint8 **buffer, uint64 *length) {
    uint8 *filebuf;
    uint32 size;
    FILE *auxfile;

    std::string fullName;
    if(baseDir != "")
        fullName = baseDir + "/" + utils::toLower(filename);
    else
        fullName = utils::toLower(filename);

    auxfile = fopen(fullName.c_str(), "rb");
    if(!auxfile) {
        printf("Unable to find auxiliary file %s\n", fullName.c_str());
        return AO_FAIL;
    }

    fseek(auxfile, 0, SEEK_END);
    size = ftell(auxfile);
    fseek(auxfile, 0, SEEK_SET);

    filebuf = (uint8 *)malloc(size);

    if(!filebuf) {
        fclose(auxfile);
        printf("ERROR: could not allocate %d bytes of memory\n", size);
        return AO_FAIL;
    }

    fread(filebuf, size, 1, auxfile);
    fclose(auxfile);

    *buffer = filebuf;
    *length = (uint64)size;

    return AO_SUCCESS;
}
}

enum {
    SIG_QSF = 0x50534641,
    SIG_SSF = 0x50534611,
    SIG_SPU = 0x53505500,
    SIG_PSF = 0x50534601,
    SIG_PSF2 = 0x50534602,
    SIG_DSF = 0x50534612
};

using namespace std;

namespace musix {

class AOPlayer : public ChipPlayer {
public:
    AOPlayer(const string &fileName) : started(false), ended(false) {

        baseDir = utils::path_directory(fileName);

        auto buffer = utils::File(fileName).readAll();

        filesig =
            buffer[0] << 24 | buffer[1] << 16 | buffer[2] << 8 | buffer[3];
        ao_display_info info;
        int rc;
        string format;
        switch(filesig) {
        case SIG_SSF:
            if(ssf_start(&buffer[0], buffer.size()) != AO_SUCCESS)
                throw player_exception();
            rc = ssf_fill_info(&info);
            format = "Sega Saturn";
            break;
        case SIG_SPU:
            if(spu_start(&buffer[0], buffer.size()) != AO_SUCCESS)
                throw player_exception();
            rc = spu_fill_info(&info);
            format = "Sony Playstation";
            break;
        case SIG_QSF:
            if(qsf_start(&buffer[0], buffer.size()) != AO_SUCCESS)
                throw player_exception();
            rc = qsf_fill_info(&info);
            format = "Capcom QSound";
            break;
        }

        if(rc == AO_SUCCESS) {
            string title = info.info[1];
            string composer = info.info[3];
            LOGD("LEN: %s", info.info[6]);
            int len = 0;
            auto p = utils::split(string(info.info[6]), ":");
            if(p.size() == 2)
                len = stol(p[0]) * 60 + stol(p[1]);
            setMeta("sub_title", title, "composer", composer, "format", format,
                    "length", len);
        } else
            LOGD("WTF");
    }
    ~AOPlayer() override { ssf_stop(); }

    int getSamples(int16_t *target, int noSamples) override {

        int rc;
        int t = noSamples / 2;
        while(t > 0) {
            int n = 1024;
            if(t < n)
                n = t;
            switch(filesig) {
            case SIG_SSF:
                rc = ssf_gen(target, n);
                break;
            case SIG_SPU:
                rc = spu_gen(target, n);
                break;
            case SIG_QSF:
                rc = qsf_gen(target, n);
                break;
            }
            target += (n * 2);
            t -= n;
        }

        // LOGD("%d %d", noSamples, rc);
        return noSamples;
    }

    virtual bool seekTo(int song, int seconds) override { return false; }

private:
    bool started;
    bool ended;
    uint32_t filesig;
    // string baseDir;
};

static const set<string> supported_ext = {"ssf", "minissf", "qsf", "miniqsf",
                                          "spu"};

bool AOPlugin::canHandle(const std::string &name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *AOPlugin::fromFile(const std::string &name) {
    try {
        return new AOPlayer{name};
    } catch(player_exception &e) {
        return nullptr;
    }
};

} // namespace musix
