#pragma once

#include <ansi/console.h>

#include <coreutils/text.h>

#include <cstdint>
#include <memory>
#include <utility>
#include <vector>

// A panel is a text grid that renders to a text console.
struct Panel : public bbs::Console
{
    Panel(std::shared_ptr<bbs::Console> _console, int _x, int _y, int _w,
          int _h, uint32_t _color = 0, int _margin = 1)
        : width{_w}, height{_h}, console{std::move(_console)}, xpos{_x},
          ypos{_y}, color{_color}, margin{_margin}
    {
        grid.resize(width * height);
        clear();
    }

    void clear();
    void clear(int x, int y, int w, int h);
    void box(int x, int y, int w, int h, uint32_t col);
    void put(std::u32string const& text, int x, int y, uint32_t fg,
             uint32_t bg);
    void put(std::string const& text, int x, int y, uint32_t fg, uint32_t bg);
    void put(std::u32string const& text, int x, int y, uint32_t fg)
    {
        put(text, x, y, fg, color);
    }
    void put(std::string const& text, int x, int y, uint32_t fg)
    {
        put(text, x, y, fg, color);
    }

    // Write the panel contents to the target console
    virtual void draw(){};
    virtual void refresh();

    template <typename String>
    void draw_text(String const& text, int x = 0, int y = 0, int w = -1,
                   int h = -1)
    {
        if (w < 0) { w = width - x; }
        if (h < 0) { h = height - y; }
        auto lines = utils::text_wrap(text, w, 0);
        // lines = utils::split(std::string(text), "\n");
        uint32_t fg = 0xffffff00;
        uint32_t bg = color;
        for (auto const& l : lines) {
            put(l, x, y, fg, bg);
            y++;
        }
    }

    void set_bg(uint32_t bg) { color = bg; }

    int get_width() const override { return width; }
    int get_height() const override { return height; }
    Tile& at(int x, int y) override { return grid.at(x + y * width); }
    void put_char(int x, int y, char32_t c) override
    {
        if (x < 0 || y < 0 || x > width || y > height) { return; }
        grid[x + y * width].c = c;
    }

    void put_color(int x, int y, uint32_t fg, uint32_t bg) override
    {
        if (x < 0 || y < 0 || x > width || y > height) { return; }
        auto& t = grid[x + y * width];
        t.fg = fg;
        t.bg = bg;
    }

    void fill(uint32_t fg, uint32_t bg) override
    {
        for (auto& t : grid) {
            t = {' ', fg, bg};
        }
    }

    void blit(int x, int y, int stride,
              std::vector<Tile> const& source) override
    {
        // TODO
    }
    void flush() override {}

    int width;
    int height;

protected:
    static char32_t box_char(char32_t a, char32_t b);
    void draw_box_char(int x, int y, char32_t c);

    std::shared_ptr<Console> console;
    int xpos;
    int ypos;
    uint32_t color;
    uint32_t fg = 0xffffff00;

    int margin = 1;

    int highlighted = -1;

    std::vector<Console::Tile> grid;
};

