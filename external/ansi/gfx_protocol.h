#include "keycodes.h"

#include <coreutils/log.h>
#include <cstdint>
#include <fmt/format.h>
#include <string>


struct GfxCommand
{
};

struct GfxProtocol
{
    static std::string goto_xy(size_t x, size_t y)
    {
        return fmt::format("\eG;{};{}", y + 1, x + 1);
    }

    // 0x000000xx -> 0xffffffxx
    // top 24 bits = true color
    // low 8 bits is color index.
    // If terminal can use RGB it should
    // If RGB != 0 AND index == 0, assume RGB must be used
    static std::string set_color(uint32_t fg, uint32_t bg)
    {
        return fmt::format("\eC;{};{}", fg, bg);
    }

    static std::string clear() { return ""; }

    static uint32_t translate_key(std::string_view seq)
    {
        return 0;
        //return std::stol(std::string(seq));
    }
};
