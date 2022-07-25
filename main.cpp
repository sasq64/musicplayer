
#include "player.hpp"
#include "ui/panel.hpp"

#include <ansi/console.h>
#include <ansi/unix_terminal.h>
#include <coreutils/log.h>

#include <fmt/format.h>

#include <atomic>
#include <chrono>
#include <csignal>
#include <memory>
#include <string>
#include <string_view>
#include <unordered_map>

using namespace std::string_literals;
using namespace std::chrono_literals;

std::string make_title(std::unordered_map<std::string, Meta> const& meta)
{
    auto title = std::get<std::string>(meta.at("title"));
    auto sub_title = std::get<std::string>(meta.at("sub_title"));
    auto game = std::get<std::string>(meta.at("game"));
    auto composer = std::get<std::string>(meta.at("composer"));

    if (title.empty()) { title = game; }
    if (!title.empty()) {
        if (!sub_title.empty()) {
            title = fmt::format("{} ({})", title, sub_title);
        }
    }
    if (!title.empty() && !composer.empty()) {
        title = fmt::format("{} / {}", title, composer);
    }
    return title;
}

int main(int argc, const char** argv)
{
    // if (argc < 2) { return 0; }

    logging::setLevel(logging::Level::Info);

    std::string songFile;
    int startSong = -1;
    bool pipe = false;
    auto music_player = MusicPlayer::create();
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            auto opt = std::string_view(&argv[i][1]);
            if (opt == "song" || opt == "s") {
                startSong = std::stoi(argv[++i]);
            } else if (opt == "p") {
                pipe = true;
            }

        } else {
            songFile = argv[i];
            music_player->play(songFile);
        }
    }

    /* if (!songFile.empty()) { */
    /*     music_player->play(songFile); */
    /* } */

    std::unique_ptr<bbs::Terminal> term =
        std::make_unique<bbs::LocalTerminal>();
    term->open();
    auto con = std::make_shared<bbs::Console>(std::move(term));

    auto con_width = con->get_width();
    // con->fill(0xff0000ff, 0x000000ff);
    Panel panel{con, 0, 0, con_width, 8};
    panel.box(0, 0, con_width - 1, 2, 0xff00ffff);
    panel.box(0, 2, con_width - 1, 2, 0xff00ffff);

    panel.box(0, 2, 16, 2, 0xff00ffff);
    panel.box(23, 2, 8, 2, 0xff00ffff);
    panel.draw_text("SONG", 18, 3);
    // panel.draw_text("Composer", 1, 2);
    // panel.draw_text("Copyright", 1, 3);
    // panel.draw_text("Format", 1, 4);
    // panel.draw_text("Length", 1, 5);
    panel.flush();
    panel.refresh();
    con->flush();
    bool output = true;

    std::unordered_map<std::string, Meta> meta;

    int song = 0;
    int songs = 0;
    int secs = 0;
    int length = 0;

    auto clear_meta = [&] {
        meta.clear();
        meta["title"] = ""s;
        meta["sub_title"] = ""s;
        meta["game"] = ""s;
        meta["composer"] = ""s;
        song = songs = secs = length = 0;
    };
    clear_meta();

    auto update_meta = [&](std::string const& name, auto val) {
        if (name == "init") {
            clear_meta();
            return;
        }
        meta[name] = val;
        if (name == "composer") {
            // panel.clear(11, 2, 30, 1);
            // panel.draw_text(std::get<std::string>(val), 11, 2);
            // } else if (name == "copyright") {
            //     panel.draw_text(std::get<std::string>(val), 11, 3);
        } else if (name == "length") {
            length = std::get<uint32_t>(val);
        } else if (name == "song") {
            song = std::get<uint32_t>(val);
        } else if (name == "songs") {
            songs = std::get<uint32_t>(val);
        } else if (name == "format") {
            panel.clear(40, 3, con_width - 40 - 1, 1);
            panel.draw_text(std::get<std::string>(val), 40, 3);
        } else if (name == "seconds") {
            secs = std::get<uint32_t>(val);
        }

        auto title = make_title(meta);
        /* if (title.empty()) { */
        /*     fs::path p = songFile; */
        /*     title = p.filename().stem().string(); */
        /* } */
        panel.clear(1, 1, con_width - 2, 1);
        panel.draw_text(title, 2, 1);
        panel.draw_text(fmt::format("{:02}/{:02}", song + 1, songs), 25, 3);
        if (length == 0) {
            panel.draw_text(fmt::format("{:02}:{:02}", secs / 60, secs % 60), 2,
                            3);
        } else {
            panel.draw_text(fmt::format("{:02}:{:02} / {:02}:{:02}", secs / 60,
                                        secs % 60, length / 60, length % 60),
                            2, 3);
        }
    };

    static std::atomic<bool> quit{false};

    std::signal(SIGINT, [](int) { quit = true; });
    // std::signal(SIGSTOP, [](int) { quit = true; });

    using clk = std::chrono::system_clock;

    std::array<int16_t, 1024 * 16> temp{};
    auto start = clk::now();
    int64_t last_secs = -1;
    while (!quit) {
        auto secs = (std::chrono::duration_cast<std::chrono::seconds>(
                         clk::now() - start))
                        .count();
        if (output) {
            auto&& info = music_player->get_info();
            for (auto&& [name, val] : info) {
                update_meta(name, val);
            }

            if (info.empty()) {
                panel.refresh();
                con->flush();
            }

            auto key = con->read_key();
            if (key == KEY_NONE) { std::this_thread::sleep_for(100ms); }
            if (key == KEY_ESCAPE) {
                music_player->detach();
                quit = true;
            }
            if (key == KEY_ENTER || key == 'n') { music_player->next(); }
            if (key == KEY_RIGHT) { music_player->set_song(++song); }
            if (key == KEY_LEFT) { music_player->set_song(--song); }
        }
    }
    music_player = nullptr;
    return 0;
}
