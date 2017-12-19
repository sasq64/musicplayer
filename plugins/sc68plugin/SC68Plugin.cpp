
#include "SC68Plugin.h"
#include "../../chipplayer.h"

#include <coreutils/file.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <string.h>

#include <sc68/msg68.h>
#include <sc68/sc68.h>
extern "C" {
int unice68_depacker(void* dest, const void* src);
int unice68_get_depacked_size(const void* buffer, int* p_csize);
}
#include <set>
#include <string>
#include <unordered_map>

using namespace std;
using namespace utils;

static void write_debug(int level, void* cookie, const char* fmt,
                        va_list list) {
    static char temp[1024];
    vsprintf(temp, fmt, list);
    LOGD(temp);
}

namespace musix {

class SC68Player : public ChipPlayer {
public:
    SC68Player(vector<uint8_t> data, string dataDir)
        : sc68(nullptr), dataDir(dataDir), valid(false) {

        string head = string((char*)&data[0], 0, 4);
        if(head == "ICE!") {
            int dsize = unice68_get_depacked_size(&data[0], NULL);
            LOGD("Unicing %d bytes to %d bytes", data.size(), dsize);
            uint8_t* ptr = new uint8_t[dsize];
            int res = unice68_depacker(ptr, &data[0]);
            if(res == 0) {
                valid = load(ptr, dsize);
            }

            delete[] ptr;

        } else {
            valid = load(&data[0], data.size());
        }
        if(valid)
            setMeta("format", "SC68");
    }

    bool load(uint8_t* ptr, int size) {

        sc68_init_t init68;
        memset(&init68, 0, sizeof(init68));
        init68.msg_handler = (sc68_msg_t)write_debug;

        if(sc68_init(&init68) != 0) {
            LOGW("Init failed");
            return false;
        }

        sc68 = sc68_create(NULL);
        sc68_set_user(sc68, dataDir.c_str());

        if(sc68_verify_mem(ptr, size) < 0) {
            LOGW("Verify mem failed");
            sc68_destroy(sc68);
            sc68 = nullptr;
            sc68_shutdown();
            return false;
        }

        if(sc68_load_mem(sc68, ptr, size)) {
            LOGW("Load mem failed");
            sc68_destroy(sc68);
            sc68 = nullptr;
            sc68_shutdown();
            return false;
        }

        sc68_music_info_t info;
        if(sc68_music_info(sc68, &info, 0, 0) == 0) {
            LOGD("%s - %s %d %d %d", info.artist, info.title, info.loop_ms,
                 info.dsk.time_ms, info.trk.time_ms);
        }

        setMeta("title", info.title, "composer", info.artist, "length",
                info.trk.time_ms / 1000);

        trackChanged = false;

        sc68_play(sc68, 0, 0);
        if(sc68_process(sc68, NULL, 0) < 0) {
            LOGW("Process failed");
            sc68_destroy(sc68);
            sc68 = nullptr;
            sc68_shutdown();
            return false;
        }

        defaultTrack = sc68_play(sc68, -1, 0);

        if(defaultTrack == 0)
            defaultTrack = 1;

        currentTrack = defaultTrack;

        return true;
    }

    ~SC68Player() override {
        if(sc68)
            sc68_destroy(sc68);
        sc68 = nullptr;
        if(valid)
            sc68_shutdown();
    }

    virtual int getSamples(int16_t* target, int noSamples) override {
        const char* err = nullptr;
        while(NULL != (err = sc68_error_get(sc68))) {
            LOGW("ERROR: %s", err);
        }

        /* Set track number : command line is prior to config force-track */
        if(currentTrack < 0) {
            currentTrack = 0;
            if(sc68_play(sc68, currentTrack, 0)) {
                return -1;
            }
        }

        int n = noSamples / 2;

        int code = sc68_process(sc68, target, &n);

        if(!trackChanged && (code & SC68_CHANGE)) {
            LOGD("Ending track");
            return -1;
        }

        trackChanged = false;

        if(code == SC68_ERROR) {
            return -1;
        }

        return noSamples;
    }

    virtual bool seekTo(int song, int seconds) override {

        if(song >= 0) {
            currentTrack = song + 1;
            if(sc68_play(sc68, currentTrack, 0)) {
                currentTrack = -1;
                return false;
            }
            trackChanged = true;
        }

        if(seconds >= 0) {
            int status;
            sc68_seek(sc68, seconds * 1000, &status);
        }
        return true;
    }

    bool isValid() { return valid; }

private:
    sc68_t* sc68;
    sc68_music_info_t info;
    int currentTrack;
    int defaultTrack;
    bool trackChanged;
    string dataDir;
    bool valid;
};

static const set<string> supported_ext{"sndh", "sc68", "snd"};

bool SC68Plugin::canHandle(const std::string& name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* SC68Plugin::fromFile(const std::string& fileName) {
    utils::File file{fileName};

    SC68Player* player = new SC68Player{file.readAll(), dataDir};
    if(player->isValid())
        return player;
    delete player;
    return nullptr;
};

} // namespace musix
