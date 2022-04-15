#pragma once

#include <functional>
#include <memory>
#include <stdexcept>
#include <string>

class audio_exception : public std::exception {
public:
    explicit audio_exception(const std::string &msg) : msg(msg) {}
    const char *what() const noexcept override { return msg.c_str(); }

    std::string msg;
};

class InternalPlayer;

class AudioPlayer {
public:
    explicit AudioPlayer(int hz);
    explicit AudioPlayer(std::function<void(int16_t *, int)> cb, int hz = 44100);
    virtual ~AudioPlayer() = default;

    virtual void play(std::function<void(int16_t *, int)> cb);
    virtual void close();

    virtual void pause();
    virtual void resume();

    virtual void set_volume(int percent);

    virtual void touch() const {}

    virtual int get_delay();

private:
        std::shared_ptr<InternalPlayer> internalPlayer;
};

