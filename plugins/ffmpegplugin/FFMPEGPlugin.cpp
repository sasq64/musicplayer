
#include "FFMPEGPlugin.h"
#include "../../chipplayer.h"

#include <coreutils/exec.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <set>
#include <unordered_map>

namespace musix {

class FFMPEGPlayer : public ChipPlayer
{
public:
    explicit FFMPEGPlayer(const std::string& /*ffmpeg*/) {}

    FFMPEGPlayer(const std::string& fileName, const std::string& ffmpeg)
    {
        pipe = utils::execPipe(
            fmt::format("{} -i \"{}\" -v error -ac 2 -ar 44100 -f s16le -",
                        ffmpeg, fileName));
    }

    ~FFMPEGPlayer() override { pipe.Kill(); }

    int getSamples(int16_t* target, int noSamples) override
    {
        int rc = pipe.read(reinterpret_cast<uint8_t*>(target), noSamples * 2);
        if (rc == -1) { return 0; }
        return rc / 2;
    }

    bool seekTo(int /*song*/, int /*seconds*/) override { return false; }

private:
    utils::ExecPipe pipe;
};

FFMPEGPlugin::FFMPEGPlugin()
{
#ifdef _WIN32
    ffmpeg = "bin\\ffmpeg.exe";
#elif defined __APPLE__
    auto xd = utils::get_exe_dir();
    std::string search_path =
        utils::make_search_path({xd, fs::absolute(xd / ".." / ".." / "bin"),
                                 fs::absolute(xd / ".." / "Resources" / "bin")},
                                false);
    LOGD("PATH IS '{}'", search_path);
    ffmpeg = utils::find_path(search_path, "ffmpeg");
    if (ffmpeg.empty()) { ffmpeg = "ffmpeg"; }
#else
    ffmpeg = "ffmpeg";
#endif
    LOGD("FFMPEG IS '{}'", ffmpeg);
}

bool FFMPEGPlugin::canHandle(const std::string& name)
{
    auto ext = utils::path_extension(name);
    return ext == "m4a" || ext == "aac";
}

ChipPlayer* FFMPEGPlugin::fromFile(const std::string& fileName)
{
    return new FFMPEGPlayer{fileName, ffmpeg};
};

ChipPlayer* FFMPEGPlugin::fromStream(std::shared_ptr<utils::Fifo<uint8_t>> fifo)
{
    return new FFMPEGPlayer(ffmpeg);
}
} // namespace musix
