
#pragma once

#include "player.hpp"

#include <ansi/console.h>
#include <ansi/unix_terminal.h>

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

    bool useColors = true;

private:
    std::shared_ptr<bbs::Console> console;
    using Loc = std::tuple<int, int, int>;
    // std::unordered_map<std::string, Loc> vars;
    std::vector<Target> targets;
    uint32_t var_fg = bbs::Console::DefaultColor;
    uint32_t var_bg = bbs::Console::DefaultColor;

    std::string panelText = R"(
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

    int parse_panel(std::string& panel)
    {
        std::string name;
        std::vector<std::u32string> lines;
        std::stringstream ss(panel);
        std::string lin;

        while (std::getline(ss, lin, '\n')) {
            if (lin.empty()) { continue; }
            lines.push_back(utils::utf8_decode(lin));
        }

        for (auto& line : lines) {
            auto pos = line.find(U"$>");
            if (pos != std::string::npos) {
                line.erase(pos, 2);
                auto c = line[pos];
                auto add_size = console->get_width() - line.length();
                auto filler = std::u32string(add_size, c);
                line.insert(pos, filler);
            }
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
        return static_cast<int>(lines.size());
    }

public:
    explicit Panel()
    {
        std::unique_ptr<bbs::Terminal> term =
            std::make_unique<bbs::LocalTerminal>();
        term->open();
        console = std::make_shared<bbs::Console>(std::move(term));
        console->set_xy(0, 0);
    }

    std::pair<int, int> find(std::string const& pattern)
    {
        return console->find(pattern);
    }

    virtual ~Panel() = default;

    void set_var_color(uint32_t fg = 0, uint32_t bg = 0)
    {
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
        if (!p.empty()) { panelText = p; }
        int height = parse_panel(panelText);
        console->init(height, useColors);
        if (p.empty()) { console->set_color(0x20e020ff); }
        console->put(panelText);
        if (p.empty()) {
            if (auto* target = get_var("sub_title")) {
                target->fg = 0xa0a0a0ff;
            }
            if (auto* target = get_var("format")) { target->fg = 0x8080ffff; }
        }
    }

    void set_color(uint32_t fg, uint32_t bg) { console->set_color(fg, bg); }
    void set_color(uint32_t fg) { console->set_color(fg); }

    void colorize(int x, int y, int w, int h) { console->colorize(x, y, w, h); }

    void flush() { console->flush(); }

    int read_key() { return console->read_key(); }

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
