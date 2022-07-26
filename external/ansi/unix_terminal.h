#pragma once

#include "terminal.h"

#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/utils.h>

#include <cassert>
#include <cstring>
#include <string>
#include <tuple>

#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

using namespace std::string_literals;

namespace bbs {

struct LocalTerminal : public Terminal
{
    ~LocalTerminal() override
    {
        if (is_open) { close(); }
    }

    void open() override
    {
        termios new_term_attr{};
        // set the terminal to raw mode
        // LOGD("Setting RAW mode");
        if (tcgetattr(fileno(stdin), &orig_term_attr) < 0) { LOGD("FAIL"); }
        is_open = true;
        memcpy(&new_term_attr, &orig_term_attr, sizeof(struct termios));
        new_term_attr.c_lflag &= ~(ECHO | ICANON);
        new_term_attr.c_cc[VTIME] = 1;
        new_term_attr.c_cc[VMIN] = 0;
        if (tcsetattr(fileno(stdin), TCSANOW, &new_term_attr) < 0) {
            LOGD("FAIL");
        }
        /* write("\x1b[6n"); */
        /* fflush(stdout); */
        /* std::string target; */
        /* while (true) { */
        /*     utils::sleepms(10); */
        /*     auto done = read(target); */
        /*     if (done) break; */
        /* } */
        /* target.resize(strlen(target.c_str())); */
        /* fmt::print("'{}' {}\n", target, target.size()); */
        /* fflush(stdout); */
        /* if (!target.empty() && target[0] == 0x1b && target[1] == '[') { */
        /*     auto [row, col] = utils::splitn<2>(target.substr(2), ";"s); */
        /*     col = col.substr(0, col.length() - 1); */
        /*     //{std::stoi(row), std::stoi(col)}; */
        /* } */

        if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) < 0) { LOGD("IOCTL FAIL"); }

        setvbuf(stdout, nullptr, _IONBF, 0);
    }

    int width() const override { return ws.ws_col; }

    int height() const override { return ws.ws_row; }


    static std::pair<int, int> get_size()
    {
        winsize ws{};
        if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) < 0) { LOGD("IOCTL FAIL"); }
        return std::make_pair(ws.ws_row, ws.ws_col);
    }

    void close() override
    {
        tcsetattr(fileno(stdin), TCSANOW, &orig_term_attr);
    }

    size_t write(std::string_view source) override
    {
        auto rc = ::write(fileno(stdout), source.data(), source.length());
        assert(rc == source.length());
        fsync(fileno(stdout));
        return rc;
    }

    bool read(std::string& target) override
    {
        auto size = target.capacity();
        if (size <= 0) {
            size = 8;
            target.resize(size);
        }
        auto rc = ::read(0, target.data(), size - 1);
        if (rc <= 0) { return false; }
        //if (rc < 0) { throw std::exception(); }
        target[rc] = 0;
        return true;
    }

private:
    termios orig_term_attr;
    winsize ws;
    bool is_open;
};

} // namespace bbs
