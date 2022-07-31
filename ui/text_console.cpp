#include "text_console.hpp"

#include <ansi/console.h>
#include <keycodes.h>
#include <ansi/terminal.h>

TextConsole::TextConsole(int width, int height)
{
    auto terminal = bbs::create_local_terminal();
    terminal->open();
    ansi_console = std::make_shared<bbs::Console>(std::move(terminal));

    width = ansi_console->get_width();
    height = ansi_console->get_height();
}

TextConsole::TextConsole(int width, int height, bool)
{
    ansi_console = std::make_shared<bbs::Console>(width, height);
}


void TextConsole::flush()
{
    ansi_console->flush();
}

int TextConsole::get_width()
{
    return ansi_console->get_width();
}

int TextConsole::get_height()
{
    return ansi_console->get_height();
}

void TextConsole::put_char(int x, int y, char32_t c)
{
    ansi_console->put_char(x, y, c, 0);
}

void TextConsole::put_color(int x, int y, uint32_t fg, uint32_t bg)
{
    ansi_console->put_color(x, y, fg, bg);
}

TextConsole::Char TextConsole::get(int x, int y)
{
    Char t{};
    auto [c, fg, bg, _] = ansi_console->at(x, y);
    t.c = c;
    t.fg = fg;
    t.bg = bg;
    return t;
}

uint32_t TextConsole::read_key()
{
    return ansi_console->read_key();
}

void TextConsole::blit(int x, int y, int w, std::vector<Char> const& source)
{
    auto tiles = utils::transform_to<std::vector<bbs::Console::Tile>>(
        source, [](auto const& tile) {
            return bbs::Console::Tile{tile.c, tile.fg, tile.bg, 0};
        });
    ansi_console->blit(x, y, w, tiles);
}

void TextConsole::fill(uint32_t fg, uint32_t bg)
{
    ansi_console->fill(fg, bg);
}
