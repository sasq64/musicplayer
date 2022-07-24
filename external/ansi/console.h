#pragma once

#include <coreutils/algorithm.h>
#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/utf8.h>

#include <cstdint>
#include <memory>
#include <string>
#include <unordered_set>
#include <vector>

#include <cwchar>

#include "ansi_protocol.h"
#include "terminal.h"

namespace bbs {

inline bool is_wide(char32_t c)
{
    static std::unordered_set<char32_t> wide{0x1fa78, 0x1f463, 0x1f311, 0x1f3f9,
                                             0x1f4b0, 0x1f480, 0x274c};
    return wide.count(c) > 0;
    // return c > 0xffff;
}

class Console
{
    using Protocol = AnsiProtocol;

public:
    enum AnsiColors
    {
        WHITE,
        RED,
        GREEN,
        BLUE,
        ORANGE,
        BLACK,
        BROWN,
        PINK,
        DARK_GREY,
        GREY,
        LIGHT_GREEN,
        LIGHT_BLUE,
        LIGHT_GREY,
        PURPLE,
        YELLOW,
        CYAN,
        CURRENT_COLOR = -2, // Use the currently set fg or bg color
        NO_COLOR = -1
    };

    std::unique_ptr<Terminal> terminal;
    bool useColors = false;

    explicit Console(std::unique_ptr<Terminal> terminal_)
        : terminal(std::move(terminal_))
    {

        put_fg = cur_fg;
        put_bg = cur_bg;
        // write("\x1b[?1049h");
        if (useColors) { write(Protocol::set_color(cur_fg, cur_bg)); }
        int w = terminal->width();
        int h = 8;
        // resize(terminal->width(), terminal->height());
        // write(Protocol::goto_xy(0, 0));
        // write(Protocol::clear());

        resize(w, h);
        auto [ox, oy] = get_xy();
        for (int y = 0; y < height; y++) {
            puts("");
        }
        org_x = 0;
        org_y = oy - height - 1;
        write("\x1b[?25l");
    }

    Console() = default;

    Console(int w, int h)
    {

        put_fg = cur_fg;
        put_bg = cur_bg;
        resize(w, h);
    }

    virtual ~Console()
    {
        puts("");
        if (terminal != nullptr) {
            write("\x1b[?25h");
            // write("\x1b[?1049l");
        }
    }

    using ColorIndex = uint16_t;
    using Char = char32_t;

    std::vector<uint32_t> palette;

    struct Tile
    {
        Char c = 0x20;
        uint32_t fg = 0;
        uint32_t bg = 0;
        uint16_t flags = 0;

        bool operator==(Tile const& other) const
        {
            return (other.c == c && other.fg == fg && other.bg == bg &&
                    other.flags == flags);
        }

        bool operator!=(Tile const& other) const { return !operator==(other); }
    };

    std::vector<Tile> grid;
    std::vector<Tile> old_grid;

    int32_t width = 0;
    int32_t height = 0;

    int32_t put_x = 0;
    int32_t put_y = 0;
    uint32_t put_fg = 0;
    uint32_t put_bg = 0;

    int32_t org_x = 0;
    int32_t org_y = 0;

    int32_t cur_x = 0;
    int32_t cur_y = 0;
    uint32_t cur_fg = 0xc0c0c007;
    uint32_t cur_bg = 0;

    void resize(int32_t w, int32_t h)
    {
        width = w;
        height = h;
        grid.resize(w * h);
        old_grid.resize(w * h);
        utils::fill(grid, Tile{' ', 0, 0, 0});
        utils::fill(old_grid, Tile{' ', 0, 0, 0});
    }

    virtual void blit(int32_t x, int32_t y, int32_t stride,
                      std::vector<Tile> const& grid)
    {
        int32_t i = 0;
        auto xx = x;
        for (auto const& c : grid) {
            if (xx < width && y < height) { this->grid[xx + width * y] = c; }
            xx++;
            if (++i == stride) {
                xx = x;
                y++;
                i = 0;
            }
        }
    }

    virtual void fill(uint32_t fg, uint32_t bg)
    {
        utils::fill(grid, Tile{' ', fg, bg, 0});
    }

    void set_xy(int32_t x, int32_t y)
    {
        put_x = x;
        put_y = y;
    }

    virtual std::pair<int, int> get_xy()
    {
        write("\x1b[6n");
        fflush(stdout);
        std::string target;
        target.resize(16);
        terminal->read(target);
        fflush(stdout);
        if (!target.empty() && target[0] == 0x1b && target[1] == '[') {
            auto [row, col] = utils::splitn<2>(target.substr(2), ";"s);
            col = col.substr(0, col.length() - 1);
            return {std::stoi(col), std::stoi(row)};
        }
        return {-1, -1};
    }

    void set_color(uint32_t fg, uint32_t bg)
    {
        put_fg = fg;
        put_bg = bg;
    }

    void put(std::string const& text)
    {
        auto ut = utils::utf8_decode(text);
        for (auto c : ut) {
            // TODO: UTF8 decode
            grid[put_x + width * put_y] = {static_cast<Char>(c), put_fg, put_bg,
                                           0};
            put_x++;
        }
    }

    virtual void put_char(int x, int y, Char c) { grid[x + width * y].c = c; }

    void put_char(int x, int y, Char c, uint16_t flg)
    {
        if (x < 0 || y < 0 || x >= width || y >= height) { return; }
        grid[x + width * y].c = c;
        grid[x + width * y].flags = flg;
    }

    virtual void put_color(int x, int y, uint32_t fg, uint32_t bg)
    {
        if (x < 0 || y < 0 || x >= width || y >= height) { return; }
        grid[x + width * y].fg = fg;
        grid[x + width * y].bg = bg;
    }

    virtual void put_color(int x, int y, uint32_t fg, uint32_t bg, uint16_t flg)
    {
        if (x < 0 || y < 0 || x >= width || y >= height) { return; }
        grid[x + width * y].fg = fg;
        grid[x + width * y].bg = bg;
        grid[x + width * y].flags = flg;
    }

    virtual Tile& at(int x, int y) { return grid[x + width * y]; }

    virtual Char get_char(int x, int y) { return grid[x + width * y].c; }

    virtual int32_t get_width() const { return width; }
    virtual int32_t get_height() const { return height; }

    void write(std::string_view text) const
    {
        if (terminal != nullptr) {
            terminal->write(text);
        } else {
            fmt::print(text);
        }
    }

    int32_t read_key() const
    {
        std::string target;
        if (terminal->read(target)) {
            std::string_view s = target.c_str();
            return static_cast<int32_t>(Protocol::translate_key(s));
        }
        return 0;
    }

    virtual void flush()
    {
        using namespace std::string_literals;
        int chars = 0;
        int xy = 0;
        bool skip_next = false;
        cur_x = cur_y = -1;
        for (int32_t y = 0; y < height; y++) {
            write(Protocol::goto_xy(org_x, org_y + y));
            skip_next = false;
            for (int32_t x = 0; x < width; x++) {
                auto& t0 = old_grid[x + y * width];
                auto const& t1 = grid[x + y * width];
                if (skip_next) {
                    t0 = t1;
                    skip_next = false;
                }
                if (t0 != t1) {
                    if (cur_y != y || cur_x != x) {
                        write(Protocol::goto_xy(org_x + x, org_y + y));
                        xy++;
                        cur_x = x;
                        cur_y = y;
                    }
                    if (useColors) {
                        write((t1.flags & 1) != 1
                                  ? Protocol::set_color(t1.fg, t1.bg)
                                  : Protocol::set_color(t1.bg, t1.fg));
                    }
                    terminal->write(utils::utf8_encode(std::u32string{t1.c}));
                    bool wide = is_wide(t1.c);
                    cur_x++;
                    if (wide) {
                        cur_x++;
                        skip_next = true;
                    }
                    chars++;
                    t0 = t1;
                }
            }
        }
        /* if (chars != 0) { */
        /*     static int counter = 0; */
        /*     counter++; */
        /*     write(protocol.goto_xy(60, 0)); */
        /*     write(protocol.set_color(0xffffff00, 0xff000000)); */
        /*     write("  ["s + std::to_string(counter) + ":"s +
         * std::to_string(chars) + "]  "s); */
        /* } */

        fflush(stdout);
    }

    void printAll()
    {
        int chars = 0;
        cur_x = cur_y = -1;
        for (int32_t y = 0; y < height; y++) {
            for (int32_t x = 0; x < width; x++) {
                auto const& t1 = grid[x + y * width];
                write((t1.flags & 1) != 1 ? Protocol::set_color(t1.fg, t1.bg)
                                          : Protocol::set_color(t1.bg, t1.fg));
                write(utils::utf8_encode(std::u32string{t1.c}));
                if (is_wide(t1.c)) { x++; }
                chars++;
            }
            putchar(10);
        }
        printf("\x1b[0m");
    }
};

} // namespace bbs
