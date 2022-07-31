#pragma once
#include <fmt/format.h>

inline std::string translate(std::string_view inp)
{
    static const auto args = fmt::make_format_args(fmt::arg("sword", ""),
        fmt::arg("xp1", "①"),
        fmt::arg("xp2", "②"),
        fmt::arg("dark", "[DARK]"),
        fmt::arg("consume", "❌ "),
        fmt::arg("range", "🏹 "),
        fmt::arg("boot", "👣"),
        fmt::arg("invisible", ""),
        fmt::arg("pull", "⇐ "),
        fmt::arg("push", "⇒ "),
        fmt::arg("ongoing", "∞➧"),
        fmt::arg("ring_xp2", "② ➧"),
        fmt::arg("ring", "◯ ➧"),
        fmt::arg("loose", "❌ "),
        fmt::arg("blood", "🩸"),
        fmt::arg("poison", "🕱"),
        fmt::arg("loot", "💰"),
        fmt::arg("bullseye", "◎"),
        fmt::arg("disarm", "{disarm}"),
        fmt::arg("fist", ""),
        fmt::arg("round_bonus", "<r>"),
        fmt::arg("earth", "[EARTH]"),
        fmt::arg("air", "[AIR]"),
        fmt::arg("stun", ""),
        fmt::arg("shield", "⛨"),
        fmt::arg("jump", ""));

    try {
        return fmt::vformat(inp, args);
    } catch (fmt::format_error& e) {
        return std::string(inp) + " : " + e.what();
    }
}

