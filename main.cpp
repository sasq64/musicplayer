
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
    if (title.empty()) {
        auto fn = std::get<std::string>(meta.at("filename"));
        title = fs::path(fn).stem();
    }
    if (!title.empty() && !composer.empty()) {
        title = fmt::format("{} / {}", title, composer);
    }
    return title;
}

template <typename... A> std::string to_string(std::variant<A...> const& v)
{
    return std::visit([](auto&& x) { return fmt::format("{}", x); }, v);
}

int main(int argc, const char** argv)
{
    // if (argc < 2) { return 0; }

    logging::setLevel(logging::Level::Info);

    std::string songFile;
    int startSong = -1;
    bool show = false;
    bool verbose = false;
    bool output = true;
    bool bg = false;
    bool writeOut = false;
    std::string command;
    std::string report;

    std::vector<fs::path> songFiles;
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            auto opt = std::string_view(&argv[i][1]);
            if (opt == "song" || opt == "s") {
                startSong = std::stoi(argv[++i]);
            } else if (opt == "p") {
                report = std::string(argv[++i]);
                bg = true;
            } else if (opt == "v") {
                verbose = true;
                output = false;
            } else if (opt == "d") {
                bg = true;
            } else if (opt == "o") {
                writeOut = true;
            } else if (opt == "n") {
                command = "next";
                bg = true;
                return 0;
            }

        } else {
            songFile = argv[i];
            songFiles.emplace_back(songFile);
        }
    }

    auto music_player =
        writeOut ? MusicPlayer::createWriter() : MusicPlayer::create();

    if (!songFiles.empty()) {
        music_player->clear();
        for (auto&& sf : songFiles) {
            music_player->play(sf);
        }
    }

    if (!report.empty()) {
        while (true) {
            auto&& allInfo = music_player->get_info();
            for (auto&& info : allInfo) {
                fmt::print("{}\n", info.first);
                if (info.first == report) {
                    auto value = std::get<std::string>(info.second);
                    fmt::print("{}", value);
                    return 0;
                }
            }
            std::this_thread::sleep_for(10ms);
        }
    }

    if (writeOut) { return 0; }

    if (command == "n") { music_player->next(); }

    if (bg) {
        music_player->detach();
        return 0;
    }

    std::unique_ptr<bbs::Terminal> term =
        std::make_unique<bbs::LocalTerminal>();
    term->open();
    auto con = std::make_shared<bbs::Console>(std::move(term), 5);

    auto con_width = con->get_width();
    Panel panel{con, 0, 0, con_width, 8};
    if (output) {
        // con->fill(0xff0000ff, 0x000000ff);
        panel.box(0, 0, con_width - 1, 2, 0xff00ffff);
        panel.box(0, 2, con_width - 1, 2, 0xff00ffff);

        panel.box(0, 2, 16, 2, 0xff00ffff);
        panel.box(23, 2, 8, 2, 0xff00ffff);
        panel.box(31, 2, 9, 2, 0xff00ffff);
        panel.draw_text("SONG", 18, 3);
        panel.draw_text("FORMAT", 33, 3);
        panel.flush();
        panel.refresh();
        con->flush();
    }

    std::unordered_map<std::string, Meta> meta;

    int song = 0;
    int songs = 0;
    int secs = 0;
    int length = 0;
    std::string file_name;

    auto clear_meta = [&] {
        meta.clear();
        meta["title"] = ""s;
        meta["sub_title"] = ""s;
        meta["game"] = ""s;
        meta["composer"] = ""s;
        meta["filename"] = ""s;
        song = secs = length = 0;
        songs = 1;
        file_name = "";
    };
    clear_meta();

    auto update_meta = [&](std::string const& name, auto val) {
        if (verbose) { fmt::print("{}={}\n", name, to_string(val)); }
        if (!output) { return; }
        if (name == "init") {
            clear_meta();
            return;
        }
        meta[name] = val;
        if (name == "filename") {
            auto f = std::get<std::string>(val);
            file_name = fs::path(f).stem().string();
        } else if (name == "length") {
            length = std::get<uint32_t>(val);
        } else if (name == "song") {
            song = std::get<uint32_t>(val);
        } else if (name == "songs") {
            songs = std::get<uint32_t>(val);
        } else if (name == "format") {
            panel.clear(42, 3, con_width - 42 - 1, 1);
            panel.draw_text(std::get<std::string>(val), 42, 3);
        } else if (name == "seconds") {
            secs = std::get<uint32_t>(val);
        }

        auto title = make_title(meta);
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
        auto&& info = music_player->get_info();
        for (auto&& [name, val] : info) {
            update_meta(name, val);
        }
        if (output) {

            if (!info.empty()) {
                panel.refresh();
                con->flush();
            }
        }

        auto key = con->read_key();
        if (key == KEY_NONE) { std::this_thread::sleep_for(100ms); }
        if (key == KEY_ESCAPE) {
            music_player->detach();
            quit = true;
        }
        if (key == 'q') { quit = true; }
        if (key == KEY_ENTER || key == 'n') { music_player->next(); }
        if (key == KEY_RIGHT) { music_player->set_song(song + 1); }
        if (key == KEY_LEFT) { music_player->set_song(song - 1); }
    }
    music_player = nullptr;
    return 0;
}
