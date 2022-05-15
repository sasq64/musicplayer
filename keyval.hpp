#pragma once

#include <elements.hpp>

template <typename Subject, typename Text>
struct keyval_elem : public cycfi::elements::proxy<Subject>
{
    Text text;
    keyval_elem(Text t, Subject s)
        : text(std::move(t)), cycfi::elements::proxy<Subject>(std::move(s))
    {
    }

    void set_text(std::string const& t) { text->set_text(t); }
};

template <typename Subject, typename Text>
keyval_elem<cycfi::remove_cvref_t<Subject>, Text> child_text(Subject&& subject,
                                                             Text text_elem)
{
    return {text_elem, std::forward<Subject>(subject)};
}

inline auto info_keyval(std::string const& text)
{
    namespace ui = cycfi::elements;
    auto telem = ui::share(ui::static_text_box(
        "DATA GOES HERE"));// cycfi::elements::get_theme().text_box_font, 16));
    return child_text(ui::htile(ui::align_left(ui::label(text)),
                ui::align_right(ui::hold(telem))), telem);
}

