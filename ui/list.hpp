#pragma once
#include "panel.hpp"
#include <string>

struct List : public Panel
{
    List(std::shared_ptr<Console> _console, int _x, int _y, int _w, int _h,
        uint32_t _color = 0, int _margin = 1)
        : Panel(_console, _x, _y, _w, _h, _color, _margin)
    {}

    enum class Type
    {
        Label,      // Skipped when navigating
        Selectable, // Tagged with number
        Action,
        Empty,
        Folded,
        OK,
    };

    struct Item
    {
        std::string text;
        Type type = Type::Selectable;
        bool enabled = true;
        bool current = false;
        int flag = -1;
        void const* data = nullptr;
    };
     void draw() override;
    int update(int key);
    std::vector<int> get_selected() const;

    std::vector<Item> items;
protected:

    int counter = 0;
    int select_count = 2;
    int endy = 0;
};
