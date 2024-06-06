
#include "MP3Plugin.h"
#include "../../chipplayer.h"

#define MINIMP3_IMPLEMENTATION
#include "minimp3/minimp3_ex.h"

#include <coreutils/fifo.h>
#include <coreutils/split.h>
#include <coreutils/url.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>
#include <coreutils/log.h>

namespace musix {

class MP3Player : public ChipPlayer
{
public:
    explicit MP3Player(std::shared_ptr<utils::Fifo<uint8_t>> _fifo)
    {
    }

    int getHZ() override { return 44100; }


    explicit MP3Player(const std::string& fileName)
    {
        mp3dec_ex_open(&dec, fileName.c_str(), MP3D_SEEK_TO_SAMPLE);
        setMeta("format", "MP3");
    }

    ~MP3Player() override
    {
        mp3dec_ex_close(&dec);
    }
    std::shared_ptr<utils::Fifo<uint8_t>> fifo;

    int getSamples(int16_t* target, int noSamples) override
    {
         mp3dec_ex_read(&dec, (mp3d_sample_t*)target, 2*noSamples/sizeof(mp3d_sample_t));
        return noSamples;
    }

    bool seekTo(int /*song*/, int /*seconds*/) override { return false; }
private:
    mp3dec_ex_t dec;
};

bool MP3Plugin::canHandle(const std::string& name)
{
    auto ext = utils::path_extension(name);
    return ext == "mp3";
}

ChipPlayer* MP3Plugin::fromFile(const std::string& fileName)
{
    return new MP3Player{fileName};
};

ChipPlayer* MP3Plugin::fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo)
{
    return new MP3Player(fifo);
}

} // namespace musix
//
extern "C" void minimp3plugin_register()
{
    musix::ChipPlugin::addPluginConstructor([](std::string const& config) {
        return std::make_shared<musix::MP3Plugin>();
    });
}
