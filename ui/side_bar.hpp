#pragma once
#include "game_state.hpp"
#include "list.hpp"
#include "translate.hpp"

#include <coreutils/utf8.h>

struct SideBar : public List
{
    SideBar(std::shared_ptr<Console> _console, int _x, int _y, int _w, int _h,
        uint32_t _color = 0, int _margin = 1)
        : List(_console, _x, _y, _w, _h, _color, _margin)
    {}
    // Currently electing cards from this deck
    AbilityCard::Location reqDeck = AbilityCard::Location::None;
    // Number of cards to select
    int card_count = 0;
    // Currently selecting an option from these options
    std::vector<std::string> options;
    AbilityCard game_card;

    void draw_card_text(std::string const& t, int y);
    void show_gloom_card(AbilityCard const& card, int y, int select = -1);
    void update_list(GameState const& state);
    void draw() override;
};
