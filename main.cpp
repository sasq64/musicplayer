
#include "player.hpp"
#include "panel.hpp"

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
template <typename... A> std::string to_string(std::variant<A...> const& v)
{
    return std::visit([](auto&& x) { return fmt::format("{}", x); }, v);
}


class LuaPanel : public Panel
{
    std::function<void(sol::table)> render_fn;
    std::function<void()> init_fn;
    sol::state& lua;
public:
    explicit LuaPanel(sol::state& _lua, std::shared_ptr<bbs::Console> _console)
        : lua(_lua), Panel(std::move(_console))
    {
    }

    void init()
    {
        if (init_fn) {
            init_fn();
        }
    }

    void render(std::unordered_map<std::string, Meta>& meta) override
    {
        make_title(meta);
        sol::table t = lua.create_table();
        for(auto [name, val] : meta) {
            std::visit([&,n=name](auto&& v) { t[n] = v; }, val);
        }
        render_fn(t);
    }

    void set_render_fn(std::function<void(sol::table)> const& f) {
        render_fn = f;
    }
    void set_init_fn(std::function<void()> const& f) {
        init_fn = f;
    }

};


int main(int argc, const char** argv)
{
    logging::setLevel(logging::Level::Info);

    sol::state lua;

    lua.open_libraries(sol::lib::base, sol::lib::string, sol::lib::table);

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
            } else if (opt == "p") {
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

    if (command == "next") { music_player->next(); }

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

    LuaPanel panel{lua, con};


    lua["set_theme"] = [&](sol::table args) {
        std::string panelText = args["panel"];
        int sx = args["stretch_x"];
        panel.set_panel(panelText, sx);
        sol::lua_value v = args["render_fn"];
        panel.set_render_fn(v.as<std::function<void(sol::table)>>());

        v = args["init_fn"];
        panel.set_init_fn(v.as<std::function<void()>>());
    };

    lua["YELLOW"] = 0xffff00ff;
    lua["GREEN"] = 0x00ff00ff;
    lua["WHITE"] = 0xffffffff;

    lua["draw"] = [&](std::string const& id, std::string const& txt, uint32_t color) {
        //fmt::print("{} {}\n", id, txt);
        panel.put(id, txt, color);
    };


    auto res = lua.script_file("theme.lua");
    if (!res.valid()) { fmt::print("ERROR\n"); }

    panel.init();
    con->flush();

    std::unordered_map<std::string, Meta> meta;

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
                panel.render(meta);
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
        if (key == KEY_RIGHT || key == ']') {
            music_player->set_song(song + 1);
        }
        if (key == KEY_LEFT || key == '[') { music_player->set_song(song - 1); }
    }
    music_player = nullptr;
    return 0;
}
