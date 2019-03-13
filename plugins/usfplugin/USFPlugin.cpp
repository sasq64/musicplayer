
#include <stdio.h>
#include <stdlib.h>
//#include <unistd.h>
//#include <types.h>
//#include <endian.h>

#include <psf/PSFFile.h>
#include "USFPlugin.h"
#include <coreutils/utils.h>
#include <set>

//#ifdef ARCH_MIN_ARM_NEON
//#include <arm_neon.h>
//#endif
// extern "C" {
//}

#include "lazyusf2/misc.h"
#include <psf/psflib.h>
#include "resampler.h"

using namespace std;

namespace musix {

class USFPlayer : public ChipPlayer {
public:
    USFPlayer(const std::string& fileName) {
        usf_state = new usf_loader_state;
        usf_state->emu_state = malloc(usf_get_state_size());
        usf_clear(usf_state->emu_state);
        sample_rate = 0;

        char temp[8192];
        strcpy(temp, fileName.c_str());

        LOGD("Trying to load USF %s", string(temp));

        if(psf_load(temp, &psf_file_system, 0x21, usf_loader, usf_state,
                    usf_info, usf_state, 1) < 0)
            throw player_exception();

        usf_set_hle_audio(usf_state->emu_state, 1);

        PSFFile psf{fileName};
        if(psf.valid()) {
            auto& tags = psf.tags();

            int seconds = psf.songLength();

            setMeta("composer", tags["artist"], "sub_title", tags["title"],
                    "game", tags["game"], "format", "Nintendo 64", "length",
                    seconds);
        }

        usf_set_compare(usf_state->emu_state, usf_state->enable_compare);
        usf_set_fifo_full(usf_state->emu_state, usf_state->enable_fifo_full);

        const char* err = usf_render(usf_state->emu_state, 0, 0, &sample_rate);
        if(err)
            LOGD("ERROR %s", err);
        LOGD("######### RATE %d", sample_rate);
        resampler_init();
        for(auto& r : resampler) {
            r = resampler_create();
            resampler_set_quality(r, RESAMPLER_QUALITY_CUBIC);
            resampler_set_rate(r, (float)sample_rate / 44100.0);
            // resampler_set_rate(r,  44100.0 / (float)sample_rate);
            resampler_clear(r);
        }
    }

    ~USFPlayer() { usf_shutdown(usf_state->emu_state); }

    virtual int getSamples(int16_t* target, int noSamples) override {

        static int16_t temp[8192];
        int sr;
        int samples_written = 0;

        while(samples_written < noSamples) {

            auto free_count = resampler_get_free_count(resampler[0]);
            if(free_count > 0) {
                const char* err =
                    usf_render(usf_state->emu_state, temp, free_count, &sr);
                if(err) {
                    LOGD("ERROR %s", err);
                    return 0;
                }
            }
            if(sr != sample_rate) {
                resampler_set_rate(resampler[0], 44100.0 / (float)sample_rate);
                resampler_set_rate(resampler[1], 44100.0 / (float)sample_rate);
                sample_rate = sr;
                LOGD("######### NEW RATE %d", sample_rate);
            }

            uint32_t avg = 0;
            for(int i = 0; i < free_count; i++) {
                resampler_write_sample(resampler[0], temp[i * 2]);
                resampler_write_sample(resampler[1], temp[i * 2 + 1]);

                avg += (std::abs(temp[i * 2]) + std::abs(temp[i * 2 + 1]));
            }

            while(samples_written < noSamples &&
                  resampler_get_sample_count(resampler[0]) > 0) {
                auto s0 = resampler_get_sample(resampler[0]);
                resampler_remove_sample(resampler[0]);
                auto s1 = resampler_get_sample(resampler[1]);
                resampler_remove_sample(resampler[1]);
                target[samples_written++] = s0;
                target[samples_written++] = s1;
            }
        }

        return samples_written;
    }

private:
    usf_loader_state* usf_state;
    void* resampler[2];
    int32_t sample_rate;
};

static const set<string> supported_ext{"usf", "miniusf"};

bool USFPlugin::canHandle(const std::string& name) {
    auto ext = utils::path_extension(name);
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* USFPlugin::fromFile(const std::string& fileName) {
    try {
        return new USFPlayer{fileName};
    } catch(player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
