#include "text_map_view.hpp"

void TextMapView::set_highlight(std::unordered_set<hex::Hex> highlight)
{
    reach_overlay.hexes = highlight;
    path_overlay.hexes = {};
}

void TextMapView::draw(GameMap& game_map)
{
    panel->fill(0xffffff01, 0x33338800);
    hex_renderer.draw_all(game_map);
}

// Set the cursor position
void TextMapView::set_cursor(hex::Hex hex)
{
    hex_renderer.cursor = hex;
    hex_renderer.cursor_color =
        (reach_overlay.hexes.count(hex) > 0) ? 0x60600000 : 0x10100000;
    auto [x, y] = hex.to_offset();
    x *= 6;
    y *= 4;
    hex_renderer.xoffs = x - width / 2;
    hex_renderer.yoffs = y - height / 2;
}

std::unordered_set<hex::Hex> TextMapView::add_set(
    std::unordered_set<hex::Hex> const& source, hex::Hex add)
{
    std::unordered_set<hex::Hex> result;
    for (auto const& h : source) {
        result.insert(h + add);
    }
    return result;
}

std::unordered_set<hex::Hex> TextMapView::rotate(
    std::unordered_set<hex::Hex> const& source)
{
    std::unordered_set<hex::Hex> result;
    for (auto h : source) {
        result.insert({-h.s, -h.q, -h.r});
    }
    return result;
}

void TextMapView::update_scrolling()
{
    auto [x, y] = cursor().to_offset();
    x *= 6;
    y *= 4;

    int cw = width;
    int ch = height;

    bool changed = false;
    if (x > hex_renderer.xoffs + (cw - 8)) {
        hex_renderer.xoffs += 10;
        changed = true;
    }
    if (x < hex_renderer.xoffs + 2) {
        hex_renderer.xoffs -= 10;
        changed = true;
    }

    if (y > hex_renderer.yoffs + (ch - 20)) {
        hex_renderer.yoffs += 5;
        changed = true;
    }
    if (y < hex_renderer.yoffs + 1) {
        hex_renderer.yoffs -= 5;
        changed = true;
    }
    if (changed) {
        panel->fill(0xffffff01, 0x33338800);
    }
}

void TextMapView::update_cursor(int key)
{
    auto c = hex_renderer.cursor;
    switch (key) {
    case 'k':
    case KEY_UP:
        c.s--;
        c.r++;
        break;
    case 'j':
    case KEY_DOWN:
        c.r--;
        c.s++;
        break;
    case 'h':
    case KEY_LEFT:
        c.r++;
        c.q--;
        break;
    case 'l':
    case KEY_RIGHT:
        c.q++;
        c.r--;
        break;
    case '/':
        area = rotate(area);
        break;
    default:
        break;
    }
    hex_renderer.cursor_color =
        (reach_overlay.hexes.count(c) > 0) ? 0x60600000 : 0x10100000;
    if (!area.empty()) {
        path_overlay.hexes = add_set(area, c);
    }

    if(c != hex_renderer.cursor) {
        update_scrolling();
        hex_renderer.cursor = c;
    }



}
