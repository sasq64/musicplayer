#include "panel.hpp"
#include <coreutils/utf8.h>

void Panel::clear()
{
    for (auto& c : grid) {
        c = {' ', fg, color};
    }
}

void Panel::clear(int x, int y, int w, int h)
{
    Tile empty{' ', fg, color};
    for (int yy = y; yy < y + h; yy++) {
        for (int xx = x; xx < x + w; xx++) {
            grid[xx + width * yy] = empty;
        }
    }
}

char32_t Panel::box_char(char32_t a, char32_t b)
{
    static const std::u32string conv = U"   ┃ ┛┓┫ ┗┏┣━┻┳╋";
    auto ao = conv.find_first_of(a);
    auto bo = conv.find_first_of(b);
    if (ao == std::string::npos) ao = 0;
    if (bo == std::string::npos) bo = 0;
    return conv[ao | bo];
}

void Panel::draw_box_char(int x, int y, char32_t c)
{
    if (x < 0 || y < 0 || x >= width || y >= height) { return; }
    auto& g = grid[x + y * width];
    g = {box_char(c, g.c), fg, color};
}

void Panel::box(int x, int y, int w, int h, uint32_t col)
{
    auto saved = fg;
    fg = col;

    for (int xx = x + 1; xx < x + w; xx++) {
        draw_box_char(xx, y, U'━');
        draw_box_char(xx, y + h, U'━');
    }
    for (int yy = y + 1; yy < y + h; yy++) {
        draw_box_char(x, yy, U'┃');
        draw_box_char(x + w, yy, U'┃');
    }

    draw_box_char(x, y, U'┏');
    draw_box_char((x + w), y, U'┓');
    draw_box_char(x, (y + h), U'┗');
    draw_box_char((x + w), (y + h), U'┛');

    fg = saved;
}

void Panel::put(std::u32string const& text, int x, int y, uint32_t fg,
                uint32_t bg)
{
    if (x < 0 || y < 0 || y >= height) { return; }
    for (auto c : text) {
        if (x >= width) return;
        // TODO: UTF8 decode
        grid[x + width * y] = {c, fg, bg};
        x++;
        if (bbs::is_wide(c)) {
            grid[x + width * y] = {1, fg, bg};
            x++;
        }
    }
}

void Panel::put(std::string const& text, int x, int y, uint32_t fg, uint32_t bg)
{
    put(utils::utf8_decode(text), x, y, fg, bg);
}

void Panel::refresh()
{
    console->blit(xpos, ypos, width, grid);
}

