#pragma once
#include "panel.hpp"

#include <game/game_map.hpp>
#include <game/tokens.hpp>
#include <hex/hex_draw.hpp>

#include <keycodes.h>

template <>
struct HexDraw<Tile>
{
    Visual operator()(hex::Hex const& h, Tile const& t) const
    {
        static const std::array<uint32_t, 9> rooms{
            // 0, 0x80008000, 0x10181000, 0, 0x20100000, 0, 0x00001000, 0, 0};
            0x80008000, 0x10181000, 0x20100000, 0x00001000, 0, 0};
        Visual res;
        res.color = rooms[t.room];
        auto [x, y] = h.to_offset();
        res.text = fmt::format("\n {},{}", x, y);
        for (Token const& token : t.tokens) {
            res = std::visit(
                [&](auto&& a) {
                    auto [color, txt] = a.render();
                    return Visual{color, txt};
                },
                token);
        };

        return res;
    }
};

struct TextMapView
{
    int width;
    int height;

    std::shared_ptr<Panel> panel;
    TextHex<Tile> hex_renderer;

    TextHex<Tile>::Overlay& reach_overlay;
    TextHex<Tile>::Overlay& path_overlay;

    std::unordered_set<hex::Hex> area;

    hex::Hex cursor() const { return hex_renderer.cursor; }

    TextMapView(int w, int h, std::shared_ptr<Console> _console)
        : width(w),
          height(h),
          panel(std::make_shared<Panel>(_console, 0, 0, w, h)),
          hex_renderer{panel, nullptr},
          reach_overlay(hex_renderer.addOverlay({}, 0x30503000)),
          path_overlay(hex_renderer.addOverlay({}, 0x30306000))
    {
        hex_renderer.size = 2;
    }

    // Highlight part of the hex map
    void set_highlight(std::unordered_set<hex::Hex> highlight);

    // Draw map to target console
    void draw(GameMap& game_map);
    void refresh() { panel->refresh(); }

    // Set the cursor position
    void set_cursor(hex::Hex hex);

    // Move the cursor according to key press
    void update_cursor(int key);

private:
    void update_scrolling();
    static std::unordered_set<hex::Hex> add_set(
        std::unordered_set<hex::Hex> const& source, hex::Hex add);

    static std::unordered_set<hex::Hex> rotate(
        std::unordered_set<hex::Hex> const& source);
};
