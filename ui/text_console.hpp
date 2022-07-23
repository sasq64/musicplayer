#pragma once

#include "console.hpp"

#include <memory>
#include <unordered_set>
#include <vector>

namespace bbs {
struct Console;
} // namespace bbs

struct TextConsole : public Console
{
    std::shared_ptr<bbs::Console> get_ansi_console() const
    {
        return ansi_console;
    }

    TextConsole(int width, int height);
    TextConsole(int width, int height, bool stupid);
    bool is_wide(char32_t) const override { return false; }
    void flush() override;
    int get_width() override;
    int get_height() override;
    void put_char(int x, int y, char32_t c) override;
    void put_color(int x, int y, uint32_t fg, uint32_t bg) override;
    Char get(int x, int y) override;
    uint32_t read_key();
    void blit(int x, int y, int w, std::vector<Char> const& source) override;
    void fill(uint32_t fg, uint32_t bg) override;

private:
    std::shared_ptr<bbs::Console> ansi_console;
};
