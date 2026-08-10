#include "AyflyPlugin.h"

#include <coreutils/utils.h>

#include "ayfly.h"

#include <algorithm>
#include <array>
#include <set>

namespace musix {

class AyflyPlayer : public ChipPlayer
{
public:
    explicit AyflyPlayer(const std::string& fileName)
    {
        aysong = ay_initsong(fileName.c_str(), 44100);
        if (aysong == nullptr) { throw player_exception("Not an AY file"); }
        const auto* songName = ay_getsongname(aysong);
        const auto* songAuthor = ay_getsongauthor(aysong);
        unsigned long len = ay_getsonglength(aysong) / 50;
        if (len > 1000) { len = 0; }
        setMeta("title", songName, "composer", songAuthor, "length", len,
                "format", "AY (Spectrum)");
    }

    ~AyflyPlayer() override
    {
        if (aysong != nullptr) ay_closesong(&aysong);
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        // ay_rendersongbuffer() takes a byte count, and renders stereo pairs
        int rc = ay_rendersongbuffer(aysong,
                                     reinterpret_cast<unsigned char*>(target),
                                     (noSamples & ~1) * 2);
        int written = rc / 2;
        // The AY DAC is unipolar; ayfly only low-pass filters so the result
        // keeps a large positive DC offset. Remove it per channel.
        for (int i = 0; i < written; i++) {
            dcBlock(target[i], dc[i & 1]);
        }
        return written;
    }

    bool seekTo(int /*song*/, int /*seconds*/) override { return false; }

private:
    struct DCState
    {
        float x{0};
        float y{0};
    };

    // One-pole DC blocker, ~5Hz corner at 44100Hz
    static void dcBlock(int16_t& sample, DCState& s)
    {
        auto x = static_cast<float>(sample);
        s.y = x - s.x + 0.9993F * s.y;
        s.x = x;
        auto v = static_cast<int32_t>(s.y);
        sample = static_cast<int16_t>(std::clamp(v, -32768, 32767));
    }

    void* aysong{nullptr};
    std::array<DCState, 2> dc{};
    bool started{false};
    bool ended{false};
};

static const std::set<std::string> supported_ext = {
    "stp2", "ay",  "psg", "asc", "stc", "psc", "sqt", "stp",
    "pt1",  "pt2", "pt3", "ftc", "vtx", "vt2", "zxs", "st13"};

bool AyflyPlugin::canHandle(const std::string& name)
{
    if (utils::toLower(name).find("/quartet") != std::string::npos)
        return false;
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* AyflyPlugin::fromFile(const std::string& name)
{
    return new AyflyPlayer{name};
};

} // namespace musix
extern "C" void ayflyplugin_register()
{
    musix::ChipPlugin::addPluginConstructor([](std::string const& config) {
        return std::make_shared<musix::AyflyPlugin>();
    });
}
