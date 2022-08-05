
#include "V2Plugin.h"

#include "sounddef.h"
#include "v2mconv.h"
#include "v2mplayer.h"

#include <coreutils/utils.h>

#include <array>
#include <set>

namespace musix {

class V2Player : public ChipPlayer
{
public:
    explicit V2Player(const std::string& fileName)
    {
        auto data = utils::read_file(fileName);

        int version = CheckV2MVersion(data.data(), static_cast<int>(data.size()));
        if (version < 0) {
            throw player_exception("Illegal version");
        }

        int converted_length = 0;
        ConvertV2M(data.data(), static_cast<int>(data.size()), &converted,
                   &converted_length);
        if (converted == nullptr) {
            throw player_exception("Could not convert");
        }

        player.Init();
        player.Open(converted);

        player.Play();
        setMeta("length", player.Length(), "format", "V2");
    }

    ~V2Player() override
    {
        player.Close();
        delete[] converted;
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        player.Render(temp.data(), noSamples / 2);
        // NOTE: Should really be normalized, values usually < 2.0 though
        for (int i = 0; i < noSamples; i++) {
            target[i] = static_cast<int16_t>(temp[i] * scaler);
        }
        return noSamples;
    }

    bool seekTo(int /*song*/, int /*seconds*/) override { return true; }

private:
    std::array<float, 150000> temp{};
    V2MPlayer player{};
    uint8_t* converted = nullptr;
    float scaler = 10000.0;
};

static const std::set<std::string> supported_ext = {"v2", "v2m"};

V2Plugin::V2Plugin()
{
    sdInit();
}

bool V2Plugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* V2Plugin::fromFile(const std::string& name)
{
    return new V2Player{name};
};

} // namespace musix
