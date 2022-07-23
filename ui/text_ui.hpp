#pragma once

#include "game_state.hpp"
#include <hex/hex.hpp>
#include <hex/hex_draw.hpp>
#include "list.hpp"
#include "panel.hpp"
#include "side_bar.hpp"
#include "text_console.hpp"
#include "text_map_view.hpp"
#include "game_proxy.hpp"
#include "game_ui.hpp"

namespace bbs {
class Console;
} // namespace bbs

#include <deque>
#include <memory>

struct TextUI : public GameUI
{
    using Hex = hex::Hex;

    TextUI(std::shared_ptr<GameProxy> _game, std::shared_ptr<TextConsole> _console);

    bool update();

private:
    std::shared_ptr<TextConsole> console;

    TextMapView game_map;
    SideBar side_bar;
    Panel info_bar;
    Panel card_panel;
    Panel msg_panel;


    std::deque<std::string> msg_lines;
    std::vector<std::string> options;
    int card_count = -1;
    int current_option = -1;
    hex::Hex cursor() const { return game_map.cursor(); }


    void update_side();

    State current_state{State::None};

    AbilityCard::Location reqDeck = AbilityCard::Location::None;

    void refresh();
    void message(std::string const& msg);

    // Set text to display during next request
    void set_selection_hint(std::string const& text);

    void handle_request(std::string const& text, OptionReq& req);
    void handle_request(std::string const& text, CardsReq& req);
    void handle_request(std::string const& text, HexReq& req);
    void handle_request(std::string const& text, AreaReq& req);
    void handle_request(std::string const& text, MultiCardsReq& req);
};
