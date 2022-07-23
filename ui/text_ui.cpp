#include "text_ui.hpp"

#include <ansi/console.h>

#include <chrono>
#include <thread>

using namespace std::chrono_literals;
using namespace std::string_literals;

using Hex = hex::Hex;

TextUI::TextUI(
    std::shared_ptr<GameProxy> _game, std::shared_ptr<TextConsole> _console)
    : console(_console),
      GameUI(_game),
      game_map{console->get_width() - 32, console->get_height(), console},
      side_bar{console, console->get_width() - 32, 1, 32,
          console->get_height() - 1, 0x30306000},
      info_bar{console, 0, 0, console->get_width(), 1, 0x60202000, 0},
      card_panel{console, 2, 2, 22, 16},
      msg_panel{console, 0, console->get_height() - 8, console->get_width(), 8,
          0x0, 0}
{}

void TextUI::message(std::string const& msg)
{
    msg_lines.push_back(msg);
    while (isize(msg_lines) > 8) {
        msg_lines.pop_front();
    }
    int y = 0;
    msg_panel.clear();
    for (auto const& l : msg_lines) {
        msg_panel.put(l, 0, y++, 0xffffff00, 0);
    }
}

void TextUI::refresh()
{
    game_map.refresh();
    info_bar.refresh();
    msg_panel.refresh();
    side_bar.refresh();
}

#if 0
void TextUI::handle_request(std::string const& text, MessageReq& req)
{
    if (text == "END") {
        current_state = State::GameEnd;
        return;
    }
    message(text);
    req.selected = 0;
    complete_request();
}
#endif

void TextUI::handle_request(std::string const& text, MultiCardsReq& req)
{
    set_selection_hint(text);
    reqDeck = req.deck;
    card_count = req.count;
    active_players = req.players;
    req.selected.resize(req.players.size());
    active_index = 0;
    game_state.player_no = active_players.at(0);
    game_map.set_cursor(game_state.players[game_state.player_no].pos);
    current_state = State::SelectingCard;
}

void TextUI::handle_request(std::string const& text, OptionReq& req)
{
    set_selection_hint(text);
    options = req.options;
    current_state = State::SelectingOption;
    current_option = req.selected;
}

void TextUI::handle_request(std::string const& text, CardsReq& req)
{
    set_selection_hint(text);
    reqDeck = req.deck;
    card_count = req.count;
    game_map.set_cursor(game_state.players[game_state.player_no].pos);
    current_state = State::SelectingCard;
}

void TextUI::handle_request(std::string const& text, HexReq& req)
{
    set_selection_hint(text);
    if (req.selected) { game_map.set_cursor(*req.selected); }
    game_map.set_highlight(req.reachable);
    current_state = State::SelectingHex;
}

void TextUI::handle_request(std::string const& text, AreaReq& req)
{
    set_selection_hint(text);
    game_map.set_cursor(*req.selected.begin());
    game_map.set_highlight(req.reachable);
    game_map.area = req.area;
    current_state = State::SelectingArea;
}

bool TextUI::update()
{
    if (check_request()) {
        std::visit([&](auto&& a) { handle_request(current_request->text, a); },
            current_request->what);
        update_side();
    }

    auto key = console->read_key();

    if (current_state == State::SelectingHex) {
        game_map.update_cursor(key);
        if ((key == KEY_ENTER &&
                game_map.reach_overlay.hexes.count(cursor()) > 0) ||
            key == KEY_ESCAPE) {
            game_map.set_highlight({});
            auto& req = std::get<HexReq>(current_request->what);
            req.selected =
                key == KEY_ENTER ? std::optional(cursor()) : std::nullopt;
            current_state = State::None;
            complete_request();
        }
    } else if (current_state == State::SelectingArea) {
        game_map.update_cursor(key);
        if ((key == KEY_ENTER &&
                game_map.reach_overlay.hexes.count(cursor()) > 0) ||
            key == KEY_ESCAPE) {
            auto& req = std::get<AreaReq>(current_request->what);
            req.selected.clear();
            if (key == KEY_ENTER) {
                req.selected = game_map.path_overlay.hexes;
            }
            game_map.set_highlight({});
            game_map.area.clear();
            current_state = State::None;
            complete_request();
        }
    } else if (current_state == State::GameEnd) {
        set_selection_hint("GameProxy has ended!");
        // if (game->victory) {
        //    message("You have cleared out all enemies!");
        //} else {
        message("You have become exhausted!");
        //}
        refresh();
        while (key != KEY_ENTER) {
            console->flush();
            key = console->read_key();
        }
    } else {
        // update_cursor(key);
        if (key == KEY_TAB || key == 'x') {
            switch_player();
            if (game_state.player_no >= 0) {
                info_bar.set_bg(game_state.players[game_state.player_no].color);
                side_bar.set_bg(game_state.players[game_state.player_no].color);
                update_side();
            }
        }
    }

    auto rc = side_bar.update(key);
    if (rc >= 0) {
        if (current_state == State::MultiCards) {
            auto& req = std::get<MultiCardsReq>(current_request->what);
            req.selected[active_index] = side_bar.get_selected();
            auto done = utils::all_of(
                req.selected, [](auto&& v) { return !v.empty(); });
            if (done) {
                complete_request();
                current_state = State::None;
            }

        } else if (current_state == State::SelectingCard) {
            auto& req = std::get<CardsReq>(current_request->what);
            req.selected = side_bar.get_selected();
            complete_request();
            current_state = State::None;
        } else if (current_state == State::SelectingOption) {
            auto& item = side_bar.items[rc];
            auto& req = std::get<OptionReq>(current_request->what);
            req.selected = item.flag;
            complete_request();
            current_state = State::None;
        }
    }

    side_bar.draw();
    game_map.draw(game_state.game_map);
    refresh();
    console->flush();
    return current_state == TextUI::State::GameEnd;
}

void TextUI::set_selection_hint(std::string const& text)
{
    info_bar.clear();
    info_bar.put(text, 0, 0, 0xffffff00);
    int x = info_bar.width - 12;
    // info_bar.put(fmt::format("SCORE: {:4}", game->score()), x, 0,
    // 0xffffff00);
}

void TextUI::update_side()
{
    using Deck = AbilityCard::Location;

    side_bar.reqDeck = (current_state == State::SelectingCard ||
                           current_state == State::MultiCards)
                           ? reqDeck
                           : Deck::None;
    side_bar.options = current_state == State::SelectingOption
                           ? options
                           : std::vector<std::string>{};
    side_bar.card_count = card_count;
    side_bar.update_list(game_state);
}
