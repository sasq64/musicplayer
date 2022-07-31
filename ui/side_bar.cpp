
#include "side_bar.hpp"
using namespace std::string_literals;

template <typename Container>
static constexpr int isize(Container const& c)
{
    return static_cast<int>(c.size());
}

void SideBar::draw_card_text(std::string const& t, int y)
{
    auto text = translate(t);

    auto text32 = utils::utf8_decode(text);
    auto lines = utils::text_wrap(text32, width - 2);
    for (auto& l : lines) {
        auto bg = color;
        uint32_t fg = 0xcccccc00;
        if (l[0] == '=') {
            l = l.substr(1);
            fg = 0xffffff00;
            bg += 0x303030;
        }
        put(l, 1 + (width - isize(l) - 2) / 2, y++, fg, bg);
    }
}

void SideBar::show_gloom_card(AbilityCard const& card, int y, int select)
{
    box(0, y, width - 1, 10, select == 0 ? 0xff000000 : 0xcccccc00);
    box(0, y + 10, width - 1, 10, select == 1 ? 0xff000000 : 0xcccccc00);

    draw_text(
        "┫ "s + std::to_string(card.initiative) + " ┣"s, width / 2 - 2, y + 10);

    draw_text(card.name, 2, y);

    draw_card_text(card.actions[0].text, y + 1);
    draw_card_text(card.actions[1].text, y + 11);
}

void SideBar::update_list(GameState const& state)
{
    using namespace std::string_literals;
    std::vector<Item> items;

    if (state.player_no >= 0) {
        color = state.players[state.player_no].color;
    }
    game_card = state.game_card;

    for (auto [elem, where] : state.elements) {
        if (where == Where::Strong || where == Where::Waning) {
            items.push_back({"  "s + to_str(elem), Type::Label, false});
        }
    }

    for (auto const& p : state.players) {
        auto text = fmt::format("{:14} {:2}/{:2} {:2}xp {}$", p.id(), p.hp,
            p.full_hp, p.xp, p.coins);
        items.push_back({text, Type::Label, false});
        auto ct = p.condition_text();
        if (!ct.empty()) {
            items.push_back({"Conditions: " + ct, Type::Label, false});
        }
    }

    for (auto const& m : state.monsters) {
        if (!m.is_active()) {
            continue;
        }
        auto text = fmt::format("{:18} {}🩸  {}👣  {}⚔ {}", m.id(),
            m.hp < 0 ? 0 : m.hp, m.stats.move, m.stats.attack,
            m.stats.range > 0 ? " "s + std::to_string(m.stats.range) + "🏹"
                              : "");
        items.push_back({text, Type::Label, false});
        auto ct = m.condition_text();
        if (!ct.empty()) {
            items.push_back({"Conditions: " + ct, Type::Label, false});
        }
    }

    if (state.player_no >= 0) {
        using Deck = AbilityCard::Location;

        std::array decks{Deck::Active, Deck::Hand, Deck::Selected,
            Deck::Discard, Deck::Lost};
        for (auto&& deck : decks) {
            bool active = reqDeck == deck;
            items.push_back({to_str(deck), Type::Label});
            bool set_current = active;
            for (AbilityCard const& card :
                state.players[state.player_no].get_set(deck)) {
                items.push_back({card.name, Type::Selectable, active});
                items.back().data = &card;
                if (set_current) {
                    items.back().current = true;
                    set_current = false;
                }
            }
            if (active) {
                items.push_back({"OK", Type::OK});
            }
        }
    }

    int i = 0;
    for (auto& opt : options) {
        items.push_back({opt, Type::Action, true});
        if (i == 0) {
            items.back().current = true;
        }
        items.back().flag = i;
        i++;
    }

    this->items = items;
    this->select_count = card_count;
}

void SideBar::draw()
{
    List::draw();
    AbilityCard const* show_card = nullptr;
    for (auto const& i : items) {
        if (i.current && i.data != nullptr) {
            show_card = static_cast<AbilityCard const*>(i.data);
            break;
        }
    }

    if (show_card == nullptr && !game_card.name.empty()) {
        show_card = &game_card;
    }

    if (show_card != nullptr) {
        show_gloom_card(*show_card, endy);
    }
}
