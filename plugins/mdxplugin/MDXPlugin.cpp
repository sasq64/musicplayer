
#include "MDXPlugin.h"
#include "../../chipplayer.h"
#include <coreutils/log.h>
#include <coreutils/url.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>
extern "C"
{
#include "mdxmini.h"
}

#include <set>
#include <string>
#include <vector>

namespace musix {

class MDXPlayer : public ChipPlayer
{
public:
    explicit MDXPlayer(const std::string& fileName)
    {

        using P = std::pair<uint16_t, uint32_t>;

        mdx_set_rate(44100);
        if (mdx_open(&song, fileName.c_str(),
                     utils::path_directory(fileName).c_str()))
            throw player_exception();

        char title[1024];
        int len = mdx_get_length(&song);
        mdx_get_title(&song, title);

        auto jis = utils::jis2unicode((uint8_t*)title);
        std::string title_utf8 = utils::utf8_encode(jis);
        LOGD("TITLE: %s", title_utf8);

        char* ptr = title;
        while (*ptr) {
            if (*ptr > 0x7f)
                *ptr = ' ';
            ptr++;
        }

        setMeta("sub_title", title_utf8, "length", len, "format", "MDX");
    }
    ~MDXPlayer() override { mdx_close(&song); }

    int getSamples(int16_t* target, int noSamples) override
    {
        int n = noSamples;
        int rc = mdx_calc_sample(&song, target, noSamples / 2);
        return noSamples;
    }

    virtual bool seekTo(int song, int seconds) override { return false; }

private:
    t_mdxmini song{};
};

static const std::set<std::string> supported_ext = {"mdx"};

bool MDXPlugin::canHandle(const std::string& name)
{
    return supported_ext.count(utils::path_extension(name)) > 0;
}

std::vector<std::string> MDXPlugin::getSecondaryFiles(const std::string& name)
{

    std::vector<uint8_t> header(2048);
    std::ifstream f(name, std::ios::in | std::ios::binary);
    f.read(reinterpret_cast<char*>(header.data()), 2048);

    for (int i = 0; i < 2045; i++) {
        if (header[i] == 0x0d && header[i + 1] == 0xa &&
            header[i + 2] == 0x1a) {
            if (header[i + 3] != 0) {
                auto pdxFile =
                    std::string(reinterpret_cast<char*>(&header[i + 3]));
                utils::makeLower(pdxFile);
                if (!utils::endsWith(pdxFile, ".pdx")) {
                    pdxFile += ".pdx";
                }
                return std::vector<std::string>{pdxFile};
            }
            break;
        }
    }
    return {};
}

ChipPlayer* MDXPlugin::fromFile(const std::string& name)
{
    return new MDXPlayer{name};
};

} // namespace musix
