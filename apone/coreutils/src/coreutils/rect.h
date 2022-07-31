#pragma once

#include <tuple>

namespace utils {

template <typename T> struct Rect
{
    Rect() {}
    Rect(T w, T h) : x(0), y(0), w(w), h(h) {}
    Rect(T x, T y, T w, T h) : x(x), y(y), w(w), h(h) {}
    union {
        T p[4];
        struct {
            T x;
            T y;
            T w;
            T h;
        };
    };
    T& operator[](const int& index) { return p[index]; }

    Rect operator/(const Rect& r) const {
        return Rect(x, y, w / r.w, h / r.h);
    }

    operator std::tuple<T, T, T, T>() const {
        return std::tuple<T, T, T, T>(x, y, w, h);
    }
};

}
