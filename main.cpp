
#include "panel.hpp"
#include "player.hpp"

#include <ansi/console.h>
#include <ansi/unix_terminal.h>
#include <coreutils/log.h>

#include <fmt/format.h>

#include <atomic>
#include <chrono>
#include <csignal>
#include <functional>
#include <locale>
#include <memory>
#include <sstream>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>

#include <sol/sol.hpp>

using namespace std::string_literals;
using namespace std::chrono_literals;

int main(int argc, const char** argv)
{
    logging::setLevel(logging::Level::Info);

    sol::state lua;

    lua.open_libraries(sol::lib::base, sol::lib::string, sol::lib::table,
                       sol::lib::io);

    std::string songFile;
    int startSong = -1;
    bool verbose = false;
    bool output = true;
    bool bg = false;
    bool clear = true;
    bool writeOut = false;
    bool quitPlayer = false;
    bool useColors = false;
    std::string command;
    std::string report;

    std::vector<fs::path> songFiles;
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            auto opt = std::string_view(&argv[i][1]);
            if (opt == "song" || opt == "s") {
                startSong = std::stoi(argv[++i]);
            } else if (opt == "color" || opt == "c") {
                useColors = true;
            } else if (opt == "r") {
                report = std::string(argv[++i]);
                bg = true;
            } else if (opt == "v") {
                verbose = true;
                output = false;
            } else if (opt == "d") {
                bg = true;
            } else if (opt == "a") {
                clear = false;
            } else if (opt == "o") {
                writeOut = true;
            } else if (opt == "q") {
                quitPlayer = true;
            } else if (opt == "n") {
                command = "next";
                bg = true;
            } else if (opt == "p") {
                command = "prev";
                bg = true;
            }

        } else {
            songFile = argv[i];
            songFiles.emplace_back(songFile);
        }
    }

    if (isatty(fileno(stdin)) == 0) {
        bg = true;
        std::string line;
        while (std::getline(std::cin, line)) {
            songFiles.emplace_back(line);
        }
        fmt::print("{} files\n", songFiles.size());
    }

    auto music_player =
        writeOut ? MusicPlayer::createWriter() : MusicPlayer::create();

    if (quitPlayer) {
        music_player->clear();
        music_player = nullptr;
        return 0;
    }

    if (startSong > 0) { music_player->set_song(startSong - 1); }
    if (!songFiles.empty()) {
        if (clear) { music_player->clear(); }
        for (auto&& sf : songFiles) {
            music_player->add(sf);
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

    if (command == "next") { music_player->next(); }
    if (command == "prev") { music_player->prev(); }

    if (bg) {
        music_player->detach();
        return 0;
    }

    std::unique_ptr<bbs::Terminal> term =
        std::make_unique<bbs::LocalTerminal>();
    term->open();
    auto con = std::make_shared<bbs::Console>(std::move(term), 8, useColors);
    con->set_color(0x00ff0000, 0);
    con->set_xy(0, 0);

    Panel panel{con};
    //panel.set_panel();
    std::unordered_map<std::string, Meta> meta;

    sol::function update_fn;
    std::unordered_map<int, std::function<void()>> mapping;

    lua["get_meta"] = [&] {
        sol::table t = lua.create_table();
        for (auto [name, val] : meta) {
            std::visit([&, n = name](auto&& v) { t[n] = v; }, val);
        }
        return t;
    };
    lua.set_function("var_color", [&](std::string const& var, uint32_t color) {
        if (auto* target = panel.get_var(var)) { target->fg = color; }
    });
    lua.set_function("map",
                     sol::overload(
                         [&](std::string key, std::function<void()> const& fn) {
                             mapping[static_cast<int>(key[0])] = fn;
                         },
                         [&](int key, std::function<void()> const& fn) {
                             mapping[key] = fn;
                         }));

    lua.set_function("colorize",
                     sol::overload(
                         [&](std::string const& pattern, uint32_t color) {
                             auto [x, y] = con->find(pattern);
                             if (x >= 0) {
                                 con->set_color(color);
                                 con->colorize(x, y, pattern.size(), 1);
                             }
                         },
                         [&](int x, int y, int len, uint32_t color) {
                             con->set_color(color);
                             con->colorize(x, y, len, 1);
                         }));

    lua["set_theme"] = [&](sol::table args) {
        std::string panelText = args["panel"];
        uint32_t panel_fg = args["panel_fg"];
        uint32_t var_fg = args["var_fg"];
        con->set_color(panel_fg);
        panel.set_color(var_fg, 0);
        if (!panelText.empty()) {
            panel.set_panel(panelText);
        }
        sol::function v = args["init_fn"];
        if (v.valid()) {
            v();
        }
        update_fn = args["update_fn"];
    };

    lua["YELLOW"] = 0xffff00ff;
    lua["GREEN"] = 0x00ff00ff;
    lua["WHITE"] = 0xffffffff;
    lua["GRAY"] = 0x808080ff;
    for (int i = KEY_F1; i <= KEY_F8; i++) {
        lua[fmt::format("KEY_F{}", i - KEY_F1 + 1)] = i;
    }

    auto dataPath = MusicPlayer::findDataPath("init.lua");

    auto res = lua.script_file(dataPath.string());
    if (!res.valid()) { fmt::print("ERROR\n"); }
    con->flush();

    uint32_t song = 0;

    auto clear_meta = [&] {
        meta.clear();
        meta["title"] = ""s;
        meta["sub_title"] = ""s;
        meta["game"] = ""s;
        meta["composer"] = ""s;
        meta["filename"] = ""s;
        meta["song"] = static_cast<uint32_t>(0);
        meta["songs"] = static_cast<uint32_t>(0);
        meta["length"] = static_cast<uint32_t>(0);
        meta["seconds"] = static_cast<uint32_t>(0);
        song = 0;
    };
    clear_meta();

    static std::atomic<bool> quit{false};

    std::signal(SIGINT, [](int) { quit = true; });

    while (!quit) {
        auto&& info = music_player->get_info();
        for (auto&& [name, val] : info) {
            if (name == "init") {
                clear_meta();
                continue;
            }
            if (name == "song") { song = std::get<uint32_t>(val); }
            meta[name] = val;
        }
        if (output) {
            if (!info.empty()) {

                panel.update(meta);
                if (update_fn.valid()) {
                    sol::table t = lua.create_table();
                    for (auto [name, val] : meta) {
                        std::visit([&, n = name](auto&& v) { t[n] = v; }, val);
                    }
                    update_fn(t);
                    for (auto&& [key, val] : t) {
                        if (val.get_type() == sol::type::number) {
                            meta[key.as<std::string>()] = val.as<uint32_t>();
                        } else {
                            meta[key.as<std::string>()] = val.as<std::string>();
                        }
                    }
                }

                panel.render(meta);
                con->flush();
            }
        }

        auto key = con->read_key();
        if (key == KEY_NONE) { std::this_thread::sleep_for(100ms); }
        auto it = mapping.find(key);
        if (it != mapping.end()) { it->second(); }
        if (key == KEY_ESCAPE) {
            music_player->detach();
            quit = true;
        }
        if (key == 'q') { quit = true; }
        if (key == KEY_ENTER || key == 'n') { music_player->next(); }
        if (key == KEY_BACKSPACE || key == 'p') { music_player->prev(); }
        if (key == KEY_RIGHT || key == ']') {
            music_player->set_song(song + 1);
        }
        if (key == KEY_LEFT || key == '[') { music_player->set_song(song - 1); }
    }
    music_player = nullptr;
    return 0;
}
