#include "elements/support/color.hpp"
#include "elements/support/theme.hpp"
#include "player.hpp"

#include "keyval.hpp"

#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <portable-file-dialogs.h>

#include <chrono>
#include <cstdio>
#include <filesystem>
#include <optional>
#include <string>
#include <unordered_map>

#include <elements.hpp>

using namespace std::chrono_literals;

namespace ui = cycfi::elements;

auto round_box(ui::color c, std::string const& text)
{
    return ui::layer(margin({5, 5, 5, 5}, ui::label(text)), ui::rbox(c, 10));
}

auto blue_button(std::string const& text)
{
    return ui::button(text, 1.0F, ui::colors::medium_blue);
    //return ui::layered_button(
    //    round_box(ui::colors::medium_blue, text),
    //    round_box(ui::colors::medium_blue.level(0.8), text));
}

class event_view : public ui::view
{
public:
    std::function<void()> on_update;
    explicit event_view(ui::window& win) : ui::view{win} {}
    void poll() override
    {
        on_update();
        ui::view::poll();
    }
};

int main(int argc, char** argv)
{
    auto this_dir = fs::current_path();
    auto player = MusicPlayer::create();
    // player->run();

    if (argc > 1) { player->play(argv[1]); }

    auto constexpr bkd_color = ui::rgba(35, 35, 37, 255);
    auto background = ui::box(bkd_color);

    ui::app app(1, argv, "player", "org.apone.music-player");
    ui::window win{app.name()};
    win.on_close = [&app]() { app.stop(); };

    event_view view{win};

    // auto theme = ui::get_theme();
    // theme.label_font_size = 20;
    // theme.text_box_font_size = 20;
    // theme.frame_stroke_width = 3;
    // theme.frame_corner_radius = 5;
    // ui::set_theme(theme);

    auto telem = ui::share(ui::static_text_box(
        "DATA  HERE"));// cycfi::elements::get_theme().text_box_font, 16));
    auto title = ui::htile(
            ui::hsize(300, ui::label("Title")), 
            ui::hsize(200, ui::hold(telem)));
    //auto title = info_keyval("Title:");
    auto composer = info_keyval("Composer:");
    auto copyright = info_keyval("Copyright:");
    auto song = info_keyval("Song:");
    auto length = info_keyval("Length:");
    //auto next_button = blue_button("Next");
    auto next_button = ui::icon_button(ui::icons::right_circled, 1.2);
    auto prev_button = ui::icon_button(ui::icons::left_circled, 1.2);

    next_button.on_click = [&](auto&&) { player->next(); };
//    prev_button.on_click = [&](auto&&) { player->prev(); };

    //auto open_button = ui::button("Open", 1.0F, ui::colors::medium_blue);
    //auto open_button = blue_button("Open");
    auto open_button = ui::icon_button(ui::icons::floppy, 1.2);

    std::optional<pfd::open_file> open_dialog{};

    open_button.on_click = [&](auto) {
        open_dialog = pfd::open_file("Choose files to read", this_dir.string(),
                                     {"All Files", "*", "Modules",
                                      "*.mod *.xm *.s3m *.ft mod.*",
                                      "C64 Files", "*.sid"},
                                     pfd::opt::none);
    };

    ui::rect m{5, 5, 5, 5};

    auto control_panel = [&] {
        return ui::layer(ui::htile(ui::margin(m, prev_button),
                                   ui::margin(m, next_button),
                                   ui::margin(m, open_button)),
                         ui::frame{});
    };
    view.content(
        ui::margin(m, ui::layer(ui::vtile(title, composer, copyright, length,
                                          song, control_panel()),
                                background)));

    view.on_update = [&] {
        auto&& info = player->get_info();
        for (auto&& [key, val] : info) {
            if (key == "title") { telem->set_text(std::get<std::string>(val)); }
            if (key == "copyright") {
                copyright.set_text(std::get<std::string>(val));
            }
            if (key == "composer") {
                composer.set_text(std::get<std::string>(val));
            }
            if (key == "length") {
                auto l = std::get<uint32_t>(val);
                length.set_text(fmt::format("{:02}:{:02}", l / 60, l % 60));
            }
            if (key == "song") {
                auto s = std::get<uint32_t>(val);
                song.set_text(fmt::format("{:02}/{:02}", s, 99));
            }
            view.refresh();
        }

        if (open_dialog && open_dialog->ready(10)) {
            auto res = open_dialog->result();
            if (!res.empty()) {
                auto fileName = fs::path(res[0]);
                this_dir = fileName;
                player->play(fileName);
            }
            open_dialog = std::nullopt;
        }
    };
    app.run();
}
