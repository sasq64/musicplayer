extern "C" {
#include "sexypsf/driver.h"
}
#include "SexyPSFPlugin.h"
#include <coreutils/fifo.h>

#include "../../chipplayer.h"
#include <coreutils/utils.h>

static utils::Fifo<int16_t>* sexyFifo;

void sexyd_update(unsigned char* pSound, long lBytes) {
    if(sexyFifo)
        sexyFifo->put((int16_t*)pSound, lBytes / 2);
}

namespace musix {

class SexyPSFPlayer : public ChipPlayer {
public:
    SexyPSFPlayer(const std::string& fileName) : fifo(1024 * 128) {
        char* temp = new char[fileName.length() + 1];
        strcpy(temp, fileName.c_str());
        sexyFifo = &fifo;
        psfInfo = sexy_load(temp);

        if(psfInfo) {
            setMeta("title", psfInfo->title ? psfInfo->title : "", "composer",
                    psfInfo->artist ? psfInfo->artist : "", "game",
                    psfInfo->game ? psfInfo->game : "", "length",
                    psfInfo->length / 1000, "copyright",
                    psfInfo->copyright ? psfInfo->copyright : "", "format",
                    "Playstation");
        }

        delete[] temp;
    }

    ~SexyPSFPlayer() {
        sexy_freepsfinfo(psfInfo);
        sexy_shutdown();
    }

    int getSamples(int16_t* target, int noSamples) {
        while(fifo.filled() < noSamples) {
            int rc = sexy_execute();
            if(rc <= 0)
                return rc;
        }
        if(fifo.filled() == 0)
            return 0;

        return fifo.get(target, noSamples);
    }

    // virtual void seekTo(int song, int seconds) {
    //}

private:
    utils::Fifo<int16_t> fifo;
    PSFINFO* psfInfo;
};

bool SexyPSFPlugin::canHandle(const std::string& name) {
    return utils::endsWith(name, ".psf");
}

ChipPlayer* SexyPSFPlugin::fromFile(const std::string& name) {
    return new SexyPSFPlayer{name};
}

} // namespace musix
