#include "list.hpp"
#include <keycodes.h>

#include <coreutils/algorithm.h>
#include <fmt/format.h>

std::vector<int> List::get_selected() const
{
    std::vector<int> result;
    int i = 0;
    for (auto const& item : items) {
        if (item.data == nullptr) {
            i = 0;
            continue;
        }
        if (item.flag >= 0) {
            if (item.flag >= result.size()) {
                result.resize(item.flag + 1);
            }
            result[item.flag] = i;
        }
        i++;
    }
    return result;
}

void List::draw()
{
    if (items.empty()) return;
    std::string spaces = "                                ";
    int y = 0;
    clear();

    int total = 0;
    for (auto& i : items) {
        if (i.flag != -1) total++;
    }
    bool isOK = (total == select_count);

    uint32_t fg = 0xc0c0c000;

    for (auto& item : items) {
        auto t = item.type;
        if (t == Type::OK && isOK) {
            t = Type::Action;
        }
        if (t == Type::Label) {
            if (item.enabled) {
                put(spaces, 0, y, color, 0xffffff00);
                put(item.text, 1, y++, color, 0xffffff00);
            } else {
                put(item.text, 0, y++, 0xffffff00, color);
            }
        } else if (t == Type::Selectable) {
            std::string text;
            uint32_t sel_bg = 0;
            uint32_t sel_fg = 0xffffff00;
            if (item.enabled) {
                char digit = ' ';
                if (item.flag >= 0) digit = '1' + item.flag;
                text = fmt::format("[{}] {}", digit, item.text);
            } else {
                sel_bg = color;
                sel_fg = 0xffffff00;
                text = fmt::format("    {}", item.text);
            }
            if (item.current) {
                put(text, 0, y++, sel_fg, sel_bg);
            } else {
                put(text, 0, y++, fg, color);
            }
        } else if (t == Type::Action) {
            if (item.current) {
                put(" >> " + item.text, 0, y++, 0xffffff00, 0);
            } else {
                put(" >> " + item.text, 0, y++, fg, color);
            }
        }
    }
    endy = y;
}

int List::update(int key)
{
    int rc = -1;
    if (items.empty()) {
        return rc;
    }
    auto it = utils::find_if(items, [](auto&& i) { return i.current; });
    if (it == items.end()) {
        it = items.begin();
        it->current = true;
    }

    it->current = false;

    int total = 0;
    for (auto const& i : items) {
        if (i.flag != -1) total++;
    }
    bool isOK = (total == select_count);

    switch (key) {
    case KEY_UP:
        while (true) {
            if (it == items.begin()) {
                it = items.end();
            }
            it--;
            if (!isOK && it->type == Type::OK) continue;
            if (it->type != Type::Label) break;
        }
        break;
    case KEY_DOWN:
        while (true) {
            it++;
            if (it == items.end()) {
                it = items.begin();
            }
            if (!isOK && it->type == Type::OK) continue;
            if (it->type != Type::Label) break;
        }
        break;
    case KEY_ENTER:
        if (it->type == Type::Selectable && it->enabled) {
            for (auto& i : items) {
                if (i.flag == counter) {
                    i.flag = -1;
                }
            }
            it->flag = counter;
            counter = (counter + 1) % select_count;
            if (select_count == 1) {
                return it - items.begin();
            }
        } else if (it->type == Type::Action || it->type == Type::OK) {
            rc = it - items.begin();
        }
        break;
    default:
        break;
    }

    it->current = true;
    return rc;
}
