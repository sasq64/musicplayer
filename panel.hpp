
#pragma once

#include "player.hpp"

#include <ansi/console.h>

#include <fmt/format.h>

#include <filesystem>
#include <functional>
#include <locale>
#include <memory>
#include <sstream>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>

namespace fs = std::filesystem;

template <typename... A> std::string to_string(std::variant<A...> const& v)
{
    return std::visit([](auto&& x) { return fmt::format("{}", x); }, v);
}

class Panel
{
public:
    struct Target
    {
        int x;
        int y;
        int length;
        std::string name;
        uint32_t fg = bbs::Console::DefaultColor;
        uint32_t bg = bbs::Console::DefaultColor;
        std::function<void(Target&)> fn;
    };

private:
    std::shared_ptr<bbs::Console> console;
    int con_width;
    using Loc = std::tuple<int, int, int>;
    // std::unordered_map<std::string, Loc> vars;
    std::vector<Target> targets;
    uint32_t var_fg = bbs::Console::DefaultColor;
    uint32_t var_bg = bbs::Console::DefaultColor;

    std::string panel = R"(
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$>━┓
┃ $title_and_composer                            $> ┃
┃ $sub_title                                     $> ┃
┣━━━━━━━━━━━━━━━┳━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━$>━┫
┃ $t_l          ┃ SONG ┃ $s_s  ┃ FORMAT ┃ $format$> ┃
┗━━━━━━━━━━━━━━━┻━━━━━━┻━━━━━━━┻━━━━━━━━┻━━━━━━━━$>━┛
)";

protected:
    static inline void make_title(std::unordered_map<std::string, Meta>& meta)
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
            meta["title_and_composer"] =
                fmt::format("{} / {}", title, composer);
        } else {
            meta["title_and_composer"] = fmt::format("{} / ???", title);
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

    void parse_panel(std::string& panel)
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
            auto pos = line.find(U"$>");
            line.erase(pos, 2);
            auto c = line[pos];
            auto add_size = con_width - line.length();
            auto filler = std::u32string(add_size, c);
            line.insert(pos, filler);
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
                    targets.push_back({xx, yy, l, name, var_fg, var_bg});
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

    virtual ~Panel() = default;

    void set_color(uint32_t fg = 0, uint32_t bg = 0) {
        var_fg = fg;
        var_bg = bg;
    }

    Target* get_var(std::string const& name)
    {
        auto it = std::find_if(targets.begin(), targets.end(),
                               [&](auto&& t) { return t.name == name; });
        if (it != targets.end()) { return &(*it); }
        return nullptr;
    }

    void set_panel(std::string const& p = ""s)
    {
        if (!p.empty()) { panel = p; }
        parse_panel(panel);
        console->put(panel);
        // put("s", "SONG", 0xffff0000);
        // put("f", "FORMAT", 0xffff0000);
    }
    //
    //    void put(std::string const& id, std::string value, uint32_t col = 0)
    //    {
    //        auto pos = vars[id];
    //        auto [x, y, l] = vars[id];
    //        console->clear(x, y, l, 1);
    //        if (value.length() >= l) { value = value.substr(0, l - 1); }
    //        console->set_xy(x, y);
    //        if (col != 0) { console->set_color(col); }
    //        console->put(value);
    //    }
    //
    //    void put(std::string const& id, uint32_t value, uint32_t col = 0)
    //    {
    //        put(id, std::to_string(value), col);
    //    }

    void put(Target const& t, Meta const& val)
    {
        console->set_color(t.fg, t.bg);
        console->clear(t.x, t.y, t.length, 1);
        auto value = to_string(val);
        if (value.length() >= t.length) {
            value = value.substr(0, t.length - 1);
        }
        console->set_xy(t.x, t.y);
        console->put(value);
    }

    virtual void update(std::unordered_map<std::string, Meta>& meta)
    {
        make_title(meta);
    }

    virtual void render(std::unordered_map<std::string, Meta>& meta)
    {
        auto length = std::get<uint32_t>(meta["length"]);
        auto song = std::get<uint32_t>(meta["song"]);
        auto songs = std::get<uint32_t>(meta["songs"]);
        auto secs = std::get<uint32_t>(meta["seconds"]);

        meta["s_s"] = fmt::format("{:02}/{:02}", song + 1, songs);
        if (length == 0) {
            meta["t_l"] = fmt::format("{:02}:{:02}", secs / 60, secs % 60);
        } else {
            meta["t_l"] = fmt::format("{:02}:{:02} / {:02}:{:02}", secs / 60,
                                      secs % 60, length / 60, length % 60);
        }

        for (auto&& target : targets) {
            auto it = meta.find(target.name);
            if (it != meta.end()) { put(target, it->second); }
        }
    }
};
