
#include "StSoundPlugin.h"
#include "../../chipplayer.h"
#include "StSoundLibrary/StSoundLibrary.h"

#include <coreutils/file.h>
#include <coreutils/utils.h>
#include <coreutils/log.h>
#include <set>
//#include <unordered_map>

using namespace std;

namespace musix {

class StSoundPlayer : public ChipPlayer {
public:
    StSoundPlayer(vector<uint8_t> data) {

        ymMusic = ymMusicCreate();
        ymMusicLoadMemory(ymMusic, &data[0], data.size());

        ymMusicInfo_t info;
        ymMusicGetInfo(ymMusic, &info);

        string name = info.pSongName;
        string author = info.pSongAuthor;
        if(name == "Unknown")
            name = "";
        if(author == "Unknown")
            author = "";

        setMeta("title", name, "composer", author, "length",
                info.musicTimeInSec, "format", info.pSongType);
        LOGD("TYPE %s PLAYER %s", info.pSongType, info.pSongPlayer);
        // printf("Name.....: %s\n",info.pSongName);
        // printf("Author...: %s\n",info.pSongAuthor);
        // printf("Comment..: %s\n",info.pSongComment);
        // printf("Duration.:
        // %d:%02d\n",info.musicTimeInSec/60,info.musicTimeInSec%60);
        // printf("Driver...: %s\n", info.pSongPlayer);
        // ymMusicSetLoopMode(pMusic,YMTRUE);
        ymMusicPlay(ymMusic);

        // setMetaData("length", ModPlug_GetLength(mod) / 1000);
        // ymMusicStop(ymMusic);
    }
    ~StSoundPlayer() override {
        if(ymMusic)
            ymMusicDestroy(ymMusic);
        ymMusic = nullptr;
    }

    virtual int getSamples(int16_t* target, int noSamples) override {

        noSamples /= 2;
        ymMusicCompute(ymMusic, target, noSamples);
        // Mono to stereo
        for(int i = noSamples - 1; i >= 0; i--) {
            target[i * 2] = target[i];
            target[i * 2 + 1] = target[i];
        }
        return noSamples * 2;
    }

    virtual bool seekTo(int song, int seconds) override {
        // if(mod)
        //	ModPlug_Seek(mod, seconds * 1000);
        ymMusicSeek(ymMusic, seconds * 1000);
        return true;
    }

private:
    YMMUSIC* ymMusic;
};

static const set<string> supported_ext{"ym", "mix"};

bool StSoundPlugin::canHandle(const std::string& name) {
    return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer* StSoundPlugin::fromFile(const std::string& fileName) {
    utils::File file{fileName};
    return new StSoundPlayer{file.readAll()};
};

} // namespace musix
