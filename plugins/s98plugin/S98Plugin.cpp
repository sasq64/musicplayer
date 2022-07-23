
#include "S98Plugin.h"
#include "../../chipplayer.h"

#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/url.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>

#include "m_s98.h"

#include <set>
#include <string>

namespace musix {

struct BIG
{};
struct LITTLE
{};

template <typename T, typename ENDIAN = LITTLE> T readmem(void* data)
{
    return *static_cast<T*>(data);
}

class S98Player : public ChipPlayer
{
public:
    explicit S98Player(const std::string& fileName)
    {

        auto buffer = utils::read_file(fileName);

        if (!song.OpenFromBuffer(&buffer[0], buffer.size())) {
            throw player_exception();
        }

        auto tagOffset = readmem<uint32_t>(&buffer[0x10]);

        if (tagOffset != 0) {
            auto tagInfo =
                std::string(reinterpret_cast<char*>(&buffer[tagOffset + 5]),
                            buffer.size() - tagOffset - 5);
            std::unordered_map<std::string, std::string> tags;
            for (const auto& line : utils::split(tagInfo, "\n")) {
                auto parts = utils::split(line, "=");
                if (parts.size() == 2) {
                    auto jis = utils::jis2unicode((uint8_t*)parts[1]);
                    std::string u = utils::utf8_encode(jis);
                    tags[utils::toLower(parts[0])] = u;
                    LOGD("%s=%s", parts[0], u);
                }
            }
            setMeta("sub_title", tags["title"], "composer", tags["artist"],
                    "year", tags["year"], "copyright", tags["copyright"]);
        }
    }
    ~S98Player() override = default;

    int getSamples(int16_t* target, int noSamples) override
    {
        int rc = song.Write(target, noSamples / 2);
        return rc * 2;
    }

     bool seekTo(int  /*song*/, int  /*seconds*/) override { return false; }

private:
    s98File song;
};

static const std::set<std::string> supported_ext = {"s98"};

bool S98Plugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* S98Plugin::fromFile(const std::string& name)
{
    return new S98Player{name};
};

} // namespace musix
