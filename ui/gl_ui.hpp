#pragma once

#include "game_state.hpp"
#include <hex/hex.hpp>
#include <hex/hex_draw.hpp>
#include "list.hpp"
#include "panel.hpp"
#include "side_bar.hpp"
#include <pix/gl_console.hpp>
#include "text_map_view.hpp"
#include "game_proxy.hpp"
#include "game_ui.hpp"

namespace bbs {
class Console;
} // namespace bbs

#include <deque>
#include <memory>

struct SDL_Window;

struct GLUI : public GameUI
{
    using Hex = hex::Hex;

    GLUI(std::shared_ptr<GameProxy> _game, int _width, int _height);

    bool update();

    void* get_window() { return window; }

private:
    SDL_Window* window;

    std::shared_ptr<GLConsole> console;

    TextMapView game_map;
    SideBar side_bar;
    Panel info_bar;
    Panel msg_panel;

    std::deque<std::string> msg_lines;
    std::vector<std::string> options;
    int card_count = -1;
    int current_option = -1;
    hex::Hex cursor() const { return game_map.cursor(); }

    static SDL_Window* setup_sdl(int w, int h);

    uint32_t read_key();
    void update_side();
    void draw();

    State current_state{State::None};

    AbilityCard::Location active_deck = AbilityCard::Location::None;

    void refresh();
    void message(std::string const& msg);

    // Set text to display during next request
    void set_selection_hint(std::string const& text);

    //void handle_request(std::string const& text, MessageReq& req);
    void handle_request(std::string const& text, OptionReq& req);
    void handle_request(std::string const& text, CardsReq& req);
    void handle_request(std::string const& text, HexReq& req);
    void handle_request(std::string const& text, AreaReq& req);
    void handle_request(std::string const& text, MultiCardsReq& req);
};
