
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

void make_title(std::unordered_map<std::string, Meta>& meta)
{
    auto title = std::get<std::string>(meta.at("title"));
    auto sub_title = std::get<std::string>(meta.at("sub_title"));
    auto game = std::get<std::string>(meta.at("game"));
    auto composer = std::get<std::string>(meta.at("composer"));

    if (title.empty()) { title = game; }

    if (title.empty()) {
        auto fn = std::get<std::string>(meta.at("filename"));
        title = fs::path(fn).stem();
    }

    meta["fixed_title"] = title;

    if (!title.empty() && !composer.empty()) {
        meta["title_and_composer"] = fmt::format("{} / {}", title, composer);
    }

    if (!title.empty()) {
        if (!sub_title.empty()) {
            title = fmt::format("{} ({})", title, sub_title);
            meta["title_and_subtitle"] = title;
        }
    }

    if (!title.empty() && !composer.empty()) {
        title = fmt::format("{} / {}", title, composer);
        meta["title_sub_composer"] = title;
    }

    meta["full_title"] = title;
}

class Panel
{
    std::shared_ptr<bbs::Console> console;
    int con_width;
    using Loc = std::tuple<int, int, int>;
    std::unordered_map<std::string, Loc> vars;

    std::string panel = R"(
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ $title                                       ┃
┣━━━━━━━━━━━━━━━┳━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━┫
┃ $time         ┃ $s   ┃ $sng  ┃ $f     ┃ $fmt ┃
┗━━━━━━━━━━━━━━━┻━━━━━━┻━━━━━━━┻━━━━━━━━┻━━━━━━┛
)";

    void parse_panel(std::string& panel, int split)
    {
        std::string name;
        // auto panel32 = utils::utf8_decode(panel);

        std::vector<std::u32string> lines;
        size_t max_len = 0;

        std::stringstream ss(panel);
        std::string lin;
        while (std::getline(ss, lin, '\n')) {
            if (lin.empty()) { continue; }
            lines.push_back(utils::utf8_decode(lin));
        }

        for (auto& line : lines) {
            auto c = line[split];
            auto add_size = con_width - line.length();
            auto filler = std::u32string(add_size, c);
            line.insert(split, filler);
        }

        int x = 0;
        int y = 0;
        bool var = false;
        bool space = false;
        Loc start;
        std::u32string out;
        for (auto& line : lines) {
            x = 0;
            for (auto c : line) {
                if (space && c != ' ') {
                    space = false;
                    auto [xx, yy, l] = start;
                    l = x - xx;
                    start = {xx, yy, l};
                    vars[name] = start;
                }
                if (var && (c > 'z' || c < 'a') && c != '_') {
                    var = false;
                    space = true;
                }
                if (var) {
                    name += static_cast<char>(c);
                    c = ' ';
                }
                if (c == '$') {
                    name = "";
                    var = true;
                    start = {x, y, 0};
                    c = ' ';
                }
                x++;
                out += c;
            }
            out += U'\n';
            y++;
        }
        panel = utils::utf8_encode(out);
    }

public:
    explicit Panel(std::shared_ptr<bbs::Console> _console)
        : console{std::move(_console)}, con_width(console->get_width())
    {
    }

    void set_panel(std::string const& p = ""s)
    {
        if (!p.empty()) { panel = p; }
        parse_panel(panel, 46);
        console->set_color(0x00ff0000, 0x000000ff);
        console->put(panel);
        put("s", "SONG", 0xffff0000);
        put("f", "FORMAT", 0xffff0000);
    }

    void put(std::string const& id, std::string value, uint32_t col = 0)
    {
        auto pos = vars[id];
        auto [x, y, l] = vars[id];
        console->clear(x, y, l, 1);
        if (value.length() >= l) { value = value.substr(0, l - 1); }
        console->set_xy(x, y);
        if (col != 0) { console->set_color(col); }
        console->put(value);
    }

    void put(std::string const& id, uint32_t value, uint32_t col = 0)
    {
        put(id, std::to_string(value), col);
    }

    void render(std::unordered_map<std::string, Meta>& meta)
    {
        make_title(meta);
        auto length = std::get<uint32_t>(meta["length"]);
        auto song = std::get<uint32_t>(meta["song"]);
        auto songs = std::get<uint32_t>(meta["songs"]);
        auto secs = std::get<uint32_t>(meta["seconds"]);
        std::string title = std::get<std::string>(meta["full_title"]);
        put("title", title, 0xffffff00);
        put("sng", fmt::format("{:02}/{:02}", song + 1, songs));
        std::string fmt = std::get<std::string>(meta["format"]);
        put("fmt", fmt, 0xe0c0ff00);

        if (length == 0) {
            put("time", fmt::format("{:02}:{:02}", secs / 60, secs % 60));
        } else {
            put("time", fmt::format("{:02}:{:02} / {:02}:{:02}", secs / 60,
                                    secs % 60, length / 60, length % 60));
        }
    }
};

template <typename... A> std::string to_string(std::variant<A...> const& v)
{
    return std::visit([](auto&& x) { return fmt::format("{}", x); }, v);
}

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
    con->set_color(0xff0000ff, 0xff00ff00);
    con->set_xy(0, 0);
    Panel panel{con};

    std::string panelText;

    lua["set_theme"] = [&](sol::table args) {
        panelText = args["panel"];
        sol::lua_value v = args["render_fn"];
        auto fn = v.as<std::function<void(sol::table)>>();
        sol::table t = lua.create_table();
        t["title"] = "test";
        t["seconds"] = 123;
        t["length"] = 123;
        //fn(t);
    };

    lua["draw"] = [](std::string const& id, std::string const& txt) {
        fmt::print("{} {}\n", id, txt);
    };

    auto res = lua.script_file("theme.lua");
    if (!res.valid()) {
        fmt::print("ERROR\n");
    }

    panel.set_panel(panelText);
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
