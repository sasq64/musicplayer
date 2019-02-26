
#include "S98Plugin.h"
#include "../../chipplayer.h"
#include <coreutils/file.h>
#include <coreutils/utils.h>
#include <coreutils/log.h>
#include <coreutils/split.h>

#include "m_s98.h"

#include <set>

using namespace std;

namespace musix {

struct BIG {};
struct LITTLE {};

template <typename T, typename ENDIAN = LITTLE> T readmem(void* data) {
    return *static_cast<T*>(data);
}

class S98Player : public ChipPlayer {
public:
    S98Player(const string& fileName) : started(false), ended(false) {

        auto buffer = utils::File(fileName).readAll();

        if(!song.OpenFromBuffer(&buffer[0], buffer.size()))
            throw player_exception();

        auto tagOffset = readmem<uint32_t>(&buffer[0x10]);

        if(tagOffset) {
            auto tagInfo = string((char*)&buffer[tagOffset + 5],
                                  buffer.size() - tagOffset - 5);
            LOGD(tagInfo);
            unordered_map<string, string> tags;
            for(const auto& line : utils::split(tagInfo, "\n")) {
                auto parts = utils::split(line, "=");
                if(parts.size() == 2) {
                    wstring jis =
                        utils::jis2unicode((uint8_t*)parts[1]);
                    string u = utils::utf8_encode(jis);
                    tags[utils::toLower(parts[0])] = u;
                    LOGD("%s=%s", parts[0], u);
                }
            }
            setMeta("sub_title", tags["title"], "composer", tags["artist"],
                    "year", tags["year"], "copyright", tags["copyright"]);
        }
    }
    ~S98Player() override {}

    int getSamples(int16_t* target, int noSamples) override {
        int rc = song.Write(target, noSamples / 2);
        return rc * 2;
    }

    virtual bool seekTo(int song, int seconds) override { return false; }

private:
    s98File song;
    bool started;
    bool ended;
};

static const set<string> supported_ext = {"s98"};

bool S98Plugin::canHandle(const std::string& name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* S98Plugin::fromFile(const std::string& name) {
    try {
        return new S98Player{name};
    } catch(player_exception& e) {
        return nullptr;
    }
};

} // namespace musix
