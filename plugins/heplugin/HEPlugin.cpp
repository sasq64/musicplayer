
#include "HEPlugin.h"

#include "he/misc.h"

#include "../../chipplayer.h"

#include <psf/PSFFile.h>

#include <coreutils/utils.h>
#include <set>
#include <unordered_map>

namespace musix {

class HEPlayer : public ChipPlayer {
public:
    HEPlayer(const std::string& fileName) {

        char temp[2048];
        strcpy(temp, fileName.c_str());

        int psf_version = psf_load(temp, &psf_file_system, 0, 0, 0, 0, 0, 0);

        PSFFile psf{fileName};
        if(psf.valid()) {
            auto& tags = psf.tags();

            int seconds = psf.songLength();

            setMeta("composer", tags["artist"], "sub_title", tags["title"],
                    "game", tags["game"], "format",
                    psf_version == 1 ? "Playstation" : "Playstation2", "length",
                    seconds);
        }

        void* psx_state = malloc(psx_get_state_size(psf_version));
        psx_clear_state(psx_state, psf_version);

        psf1_load_state lstate;

        lstate.emu = psx_state;
        lstate.first = true;
        lstate.refresh = 50;

        psf1_load_state* psinfo =
            (psf1_load_state*)malloc(sizeof(psf1_load_state));

        if(psf_version == 1) {
            if(psf_load(temp, &psf_file_system, psf_version, psf1_load, &lstate,
                        psf1_info, &lstate, 0) < 0) {
                throw player_exception();
            }
        }
        if(psf_version == 2) {
            void* psf2fs = psf2fs_create();
            if(!psf2fs) {
                throw player_exception();
            }

            psf1_load_state lstate;

            if(psf_load(temp, &psf_file_system, psf_version,
                        psf2fs_load_callback, psf2fs, psf1_info, &lstate, 0) < 0) {
                throw player_exception();
            }

            psx_set_readfile(psx_state, virtual_readfile, psf2fs);

            psinfo->psf2fs = psf2fs;
        }
        psinfo->emu = psx_state;
        psinfo->version = psf_version;
        psinfo->first = lstate.first;
        psinfo->refresh = lstate.refresh;

        state = psinfo;
    }

    ~HEPlayer() {
        if(state->version == 2)
            psf2fs_delete(state->psf2fs);
        free(state->emu);
        free(state);
    }

    virtual int getSamples(int16_t* target, int noSamples) override {

        void* psx_state = state->emu;

        uint32_t samples_cnt = noSamples / 2;

        /* int rtn = */ psx_execute((void*)psx_state, 0x7FFFFFFF, target,
                                    &samples_cnt, 0);
        if((int)samples_cnt < (noSamples / 2)) {
            noSamples = samples_cnt * 2;
        }

        return noSamples;
    }

private:
    psf1_load_state* state;
};

static const std::set<std::string> supported_ext{"psf", "psf2", "minipsf",
                                                 "minipsf2"};

bool HEPlugin::canHandle(const std::string& name) {
    auto ext = utils::path_extension(name);

    if(utils::toLower(name).find("/soundfactory") != std::string::npos)
        return false;

    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* HEPlugin::fromFile(const std::string& fileName) {

    if(!biosLoaded) {
        LOGD("Now loading '%s'", biosFileName);
        FILE* f = fopen(biosFileName.c_str(), "rb");
        if(f == NULL)
            return nullptr;

        fseek(f, 0, SEEK_END);
        int bios_size = ftell(f);
        fseek(f, 0, SEEK_SET);

        uint8_t* bios = (uint8_t*)malloc(bios_size);
        int rc = fread(bios, 1, bios_size, f);
        fclose(f);
        if(rc != bios_size)
            return nullptr;
        LOGD("Successfully loaded hebios.bin");
        bios_set_image((uint8*)bios, bios_size);

        int init_result = psx_init();
        if(init_result != 0) {
            return nullptr; // means init failed
        }

        biosLoaded = true;
    }

    try {
        return new HEPlayer{fileName};
    } catch(player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
