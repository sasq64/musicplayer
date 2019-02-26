#include "audioplayer.h"

#ifdef SDL_AUDIO
#    include "player_sdl.h"
#elif defined OSX_AUDIO
#    include "player_osx.h"
#elif defined _WIN32
#    include "player_win.h"
#elif defined LINUX
#    include "player_linux.h"
#elif defined ANDROID
#    include "player_sl.h"
#else
#    include "player_sdl.h"
#endif

AudioPlayer::AudioPlayer(int hz)
    : internalPlayer(std::make_shared<InternalPlayer>(hz))
{}

AudioPlayer::AudioPlayer(std::function<void(int16_t*, int)> cb, int hz)
    : internalPlayer(std::make_shared<InternalPlayer>(hz))
{
    internalPlayer->play(cb);
}

void AudioPlayer::play(std::function<void(int16_t*, int)> cb)
{
    internalPlayer->play(cb);
}

void AudioPlayer::close()
{
    // TODO: Uncomment if close not called from destructor
    // staticInternalPlayer = nullptr;
    // if(staticInternalPlayer)
    //  staticInternalPlayer->close();
}

void AudioPlayer::pause()
{
    internalPlayer->pause(true);
}
void AudioPlayer::resume()
{
    internalPlayer->pause(false);
}

void AudioPlayer::set_volume(int v)
{
    internalPlayer->set_volume(v);
}

int AudioPlayer::get_delay()
{
    return internalPlayer->get_delay();
}
