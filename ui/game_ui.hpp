#pragma once
#include "game_proxy.hpp"
#include "ui_request.hpp"

struct GameUI
{
    explicit GameUI(std::shared_ptr<GameProxy> const& _game) : game(_game) {}

    void complete_request()
    {
        game->complete_request(*current_request);
        current_request = std::nullopt;
    }

    bool check_request()
    {
        if (!current_request) {
            current_request = game->get_request();
            if (current_request) {
                game_state = game->get_game_state();
                return true;
            }
        }
        return false;
    }
    void switch_player()
    {
        if (active_players.empty()) { return; }
        active_index = (active_index + 1) % isize(active_players);
        game_state.player_no = active_players[active_index];
    }

    GameState game_state;
    // The player(s) that should handle the current request
    std::vector<int> active_players;
    int active_index = 0;

    std::optional<UIRequest> current_request;
    std::shared_ptr<GameProxy> game;

    enum class State
    {
        None,
        SelectingHex,
        SelectingArea,
        SelectingCard,
        SelectingOption,
        MultiCards,
        GameEnd,
    };
};
