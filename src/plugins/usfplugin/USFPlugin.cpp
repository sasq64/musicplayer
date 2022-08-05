
#include <stdio.h>
#include <stdlib.h>

#include "USFPlugin.h"
#include <coreutils/utils.h>
#include <psf/PSFFile.h>
#include <set>

#include "lazyusf2/misc.h"
#include <psf/psflib.h>

using namespace std;

namespace musix {

class USFPlayer : public ChipPlayer
{
public:
    USFPlayer(const std::string& fileName)
    {
        usf_state.emu_state = malloc(usf_get_state_size());
        usf_clear(usf_state.emu_state);
        sample_rate = 0;

        LOGD("Trying to load USF %s", fileName);

        if (psf_load(fileName.c_str(), &psf_file_system, 0x21, usf_loader, &usf_state,
                     usf_info, &usf_state, 1) < 0)
            throw player_exception();

        usf_set_hle_audio(usf_state.emu_state, 1);

        PSFFile psf{fileName};
        if (psf.valid()) {
            auto& tags = psf.tags();

            int seconds = psf.songLength();

            setMeta("composer", tags["artist"], "sub_title", tags["title"],
                    "game", tags["game"], "format", "Nintendo 64", "length",
                    seconds);
        }

        usf_set_compare(usf_state.emu_state, usf_state.enable_compare);
        usf_set_fifo_full(usf_state.emu_state, usf_state.enable_fifo_full);

        const char* err = usf_render(usf_state.emu_state, 0, 0, &sample_rate);
        if (err)
            LOGD("ERROR %s", err);
    }

    ~USFPlayer() { usf_shutdown(usf_state.emu_state); }

    int getHZ() override { return sample_rate; }

    int getSamples(int16_t* target, int noSamples) override
    {
        const char* err = usf_render(usf_state.emu_state, target,
                                     noSamples / 2, &sample_rate);
        if (err) {
            LOGD("ERROR %s", err);
            return 0;
        }
        return noSamples;
    }

private:
    usf_loader_state usf_state{};
    int32_t sample_rate = 0;
};

static const set<string> supported_ext{"usf", "miniusf"};

bool USFPlugin::canHandle(const std::string& name)
{
    auto ext = utils::path_extension(name);
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* USFPlugin::fromFile(const std::string& fileName)
{
    return new USFPlayer{fileName};
};

} // namespace musix
