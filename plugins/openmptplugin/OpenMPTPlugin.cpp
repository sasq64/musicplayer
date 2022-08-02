
#include "OpenMPTPlugin.h"

#include "openmpt/libopenmpt/libopenmpt.h"
#include "openmpt/libopenmpt/libopenmpt_stream_callbacks_file.h"

#include "../../chipplayer.h"

#include <coreutils/split.h>
#include <coreutils/utils.h>
#include <set>

namespace musix {

class OpenMPTPlayer : public ChipPlayer
{
public:
    explicit OpenMPTPlayer(std::vector<uint8_t> const& data)
    {
        const uint8_t* ptr = data.data();
        if (data.size() < 1090) { throw player_exception("Data too short"); }
        if (memcmp(ptr + 1080, "FLT", 3) == 0 ||
            memcmp(ptr + 1080, "EXO", 3) == 0) {
            throw player_exception("Can not play Startrekker module");
        }

        module = openmpt_module_create_from_memory(data.data(), data.size(),
                                                   nullptr, nullptr, nullptr);

        if (module == nullptr) {
            throw player_exception("Could not load module");
        }

        openmpt_module_set_repeat_count(module, 99);

        auto length =
            static_cast<uint32_t>(openmpt_module_get_duration_seconds(module));
        auto songs = openmpt_module_get_num_subsongs(module);

        auto get = [&](const char* what) {
            return std::string(openmpt_module_get_metadata(module, what));
        };

        auto type_long = get("type_long");
        auto type = get("type");

        auto p = utils::split(type_long, " / ");
        if (p.size() > 1) { type_long = p[0]; }

        setMeta("title", get("title"), "composer", get("artist"), "message",
                get("message"), "tracker", get("tracker"), "format", type_long,
                "type", type, "songs", songs, "length", length);

        openmpt_module_set_render_param(
            module, OPENMPT_MODULE_RENDER_INTERPOLATIONFILTER_LENGTH,
            type == "mod" ? 1 : 0);

        //auto& Settings = utils::Settings::getGroup("openmpt");
        auto separation = 100.0;
        openmpt_module_set_render_param(
           module, OPENMPT_MODULE_RENDER_STEREOSEPARATION_PERCENT, separation);
    }

    ~OpenMPTPlayer() override
    {
        if (module != nullptr) { openmpt_module_destroy(module); }
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        auto len = openmpt_module_read_interleaved_stereo(
            module, 44100, noSamples / 2, target);
        return len * 2;
    }

    bool seekTo(int song, int seconds) override
    {
        if (module != nullptr) {
            if (song >= 0) {
                openmpt_module_select_subsong(module, song);
            } else {
                openmpt_module_set_position_seconds(module, seconds);
            }
            return true;
        }
        return false;
    }

private:
    openmpt_module* module;
};

bool OpenMPTPlugin::canHandle(const std::string& n)
{
    auto name = utils::toLower(n);
    auto ext = utils::path_extension(name);
    if (ext == "gz" || ext == "rns" || ext == "dtm") { return false; }
    auto prefix = utils::path_prefix(name);
    if (prefix == "stk" || prefix == "mod" || ext == "ft") { return true; }
    return openmpt_is_extension_supported(ext.c_str()) != 0;
}

ChipPlayer* OpenMPTPlugin::fromFile(std::string const& fileName)
{
    auto data = utils::read_file(fileName);
    return new OpenMPTPlayer{data};
};

} // namespace musix
