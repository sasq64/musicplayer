#include "gl_ui.hpp"
#include <pix/pix.hpp>
#include <pix/texture_font.hpp>

#include <SDL.h>
#include <SDL2/SDL_opengl.h>

#include <chrono>
#include <thread>

using namespace std::chrono_literals;
using namespace std::string_literals;

using Hex = hex::Hex;

static uint32_t sdl2key(uint32_t code)
{
    switch (code) {
    case SDLK_LEFT: return KEY_LEFT;
    case SDLK_RIGHT: return KEY_RIGHT;
    case SDLK_UP: return KEY_UP;
    case SDLK_DOWN: return KEY_DOWN;
    case SDLK_RETURN: return KEY_ENTER;
    default: return code;
    }
}

GLUI::GLUI(std::shared_ptr<GameProxy> _game, int _width, int _height)
    : GameUI(_game),
      window(setup_sdl(_width * 8, _height * 16)),
      console(std::make_shared<GLConsole>(_width, _height)),
      game_map{_width - 32, _height, console},
      side_bar{console, _width - 32, 1, 32, _height - 1, 0x30306000},
      info_bar{console, 0, 0, _width, 1, 0x60202000, 0},
      msg_panel{console, 0, _height - 8, _width, 8, 0x0, 0}
{
    game_state = _game->get_game_state();
    update_side();
}

SDL_Window* GLUI::setup_sdl(int w, int h)
{
    SDL_Init(SDL_INIT_VIDEO);
    auto* window = SDL_CreateWindow("SDL2Test", SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED, w, h, SDL_WINDOW_OPENGL);
    SDL_GL_CreateContext(window);
    gl_wrap::setViewport({w, h});
    return window;
}

void GLUI::message(std::string const& msg)
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

void GLUI::refresh()
{
    game_map.refresh();
    info_bar.refresh();
    msg_panel.refresh();
    side_bar.refresh();
}

void GLUI::handle_request(std::string const& text, OptionReq& req)
{
    set_selection_hint(text);
    options = req.options;
    current_state = State::SelectingOption;
    current_option = req.selected;
}

void GLUI::handle_request(std::string const& text, MultiCardsReq& req)
{
    set_selection_hint(text);
    active_deck = req.deck;
    card_count = req.count;
    active_players = req.players;
    req.selected.resize(req.players.size());
    active_index = 0;
    game_state.player_no = active_players.at(0);
    game_map.set_cursor(game_state.players[game_state.player_no].pos);
    current_state = State::MultiCards;
}

void GLUI::handle_request(std::string const& text, CardsReq& req)
{
    set_selection_hint(text);
    active_deck = req.deck;
    card_count = req.count;
    game_map.set_cursor(game_state.players[game_state.player_no].pos);
    current_state = State::SelectingCard;
}

void GLUI::handle_request(std::string const& text, HexReq& req)
{
    set_selection_hint(text);
    if (req.selected) { game_map.set_cursor(*req.selected); }
    game_map.set_highlight(req.reachable);
    current_state = State::SelectingHex;
}

void GLUI::handle_request(std::string const& text, AreaReq& req)
{
    set_selection_hint(text);
    game_map.set_cursor(*req.selected.begin());
    game_map.set_highlight(req.reachable);
    game_map.area = req.area;
    current_state = State::SelectingArea;
}

uint32_t GLUI::read_key()
{
    SDL_Event e;
    while (SDL_PollEvent(&e) != 0) {
        if (e.type == SDL_TEXTINPUT) {
            // fmt::print("TEXT '{}'\n", e.text.text);
        } else if (e.type == SDL_KEYDOWN) {
            if (e.key.keysym.sym == SDLK_F5) {
                pix::Image image;
                auto& font = console->font;
                image.ptr = reinterpret_cast<std::byte*>(font->data.data());
                image.width = font->texture_width;
                image.height = font->texture_height;
                pix::save_png(image, "test.png");
                continue;
            }
            auto& ke = e.key;
            // fmt::print("KEY {:x}\n", ke.keysym.sym);
            return sdl2key(ke.keysym.sym);
        } else if (e.type == SDL_QUIT) {
            fmt::print("quit\n");
            return KEY_QUIT;
        }
    }
    return KEY_UNKNOWN;
}

bool GLUI::update()
{
    if (check_request()) {
        for (auto const& m : current_request->messages) {
            message(m.text);
        }
        std::visit([&](auto&& a) { handle_request(current_request->text, a); },
            current_request->what);
        update_side();
    }

    auto key = read_key();
    if (key == KEY_QUIT) {
        if (current_request) {
            current_request->text = "END";
            complete_request();
        }
        return true;
    }

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
            key = read_key();
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
            current_state = State::None;
            complete_request();
        } else if (current_state == State::SelectingOption) {
            auto& item = side_bar.items[rc];
            auto& req = std::get<OptionReq>(current_request->what);
            req.selected = item.flag;
            current_state = State::None;
            complete_request();
        }
    }

    side_bar.draw();
    game_map.draw(game_state.game_map);
    refresh();
    console->flush();
    draw();
    return current_state == GLUI::State::GameEnd;
}

void GLUI::draw()
{
    namespace gl = gl_wrap;

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    gl::clearColor({0xe0108000});
    glClear(GL_COLOR_BUFFER_BIT);
    int w = 0;
    int h = 0;
    SDL_GetWindowSize(window, &w, &h);
    auto& program = gl::ProgramCache::get_instance().textured;
    program.use();
    gl_wrap::setViewport({w, h});
    console->frame_buffer.bind();
    // gfx_console->font->texture.bind();
    pix::draw_quad({0, h}, {w, -h});
    SDL_GL_SwapWindow(window);
}

void GLUI::set_selection_hint(std::string const& text)
{
    info_bar.clear();
    info_bar.put(text, 0, 0, 0xffffff00);
    int x = info_bar.width - 12;
    // info_bar.put(fmt::format("SCORE: {:4}", game->score()), x, 0,
    // 0xffffff00);
}

void GLUI::update_side()
{
    using Deck = AbilityCard::Location;

    side_bar.reqDeck = (current_state == State::SelectingCard ||
                           current_state == State::MultiCards)
                           ? active_deck
                           : Deck::None;
    side_bar.options = current_state == State::SelectingOption
                           ? options
                           : std::vector<std::string>{};
    side_bar.card_count = card_count;
    side_bar.update_list(game_state);
}
