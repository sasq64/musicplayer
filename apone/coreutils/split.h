#pragma once

#include <algorithm>
#include <cstring>
#include <iostream>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

namespace utils {


template <typename ITERATOR>
std::string join(ITERATOR begin, ITERATOR end,
                 const std::string& separator = ", ")
{
    std::ostringstream ss;

    if (begin != end) {
        ss << *begin++;
    }

    while (begin != end) {
        ss << separator;
        ss << *begin++;
    }
    return ss.str();
}

template <typename T> std::string my_tos(const T& t) {
    return std::to_string(t);
}

inline std::string my_tos(const std::string& t) {
    return t;
}

template <class... ARGS>
std::string join(const std::string& sep, const ARGS&... args) {
    std::vector<std::string> v{my_tos(args)...};
    return join(v.begin(), v.end(), sep);
}

class StringSplit
{
    std::string source;
    std::vector<char*> pointers;
    char* ptr;
    const int minSplits = -1;

    void split(const char delim)
    {
        while (true) {
            pointers.push_back(ptr);
            ptr = strchr(ptr, delim);
            if (ptr == nullptr)
                break;
            *ptr++ = 0;
        }
    }

    void split(const char* delim)
    {
        const auto dz = strlen(delim);
        while (true) {
            pointers.push_back(ptr);
            ptr = strstr(ptr, delim);
            if (ptr == nullptr)
                break;
            *ptr = 0;
            ptr += dz;
        }
    }

public:
    template <typename T>
    StringSplit(T&& text, std::string const& delim, int minSplits = -1)
        : source(std::forward<T>(text)), ptr(&source[0]), minSplits(minSplits)
    {
        split(delim.c_str());
    }

    template <typename T>
    StringSplit(T&& text, const char delim, int minSplits = -1)
        : source(std::forward<T>(text)), ptr(&source[0]), minSplits(minSplits)
    {
        split(delim);
    }

    size_t size() const { return pointers.size(); }
    auto begin() const { return pointers.begin(); }
    auto end() const { return pointers.end(); }

    char const* operator[](unsigned n) const
    {
        return n < size() ? pointers[n] : nullptr;
    }
    std::string getString(unsigned n) const
    {
        static std::string empty;
        return n < size() ? std::string(pointers[n]) : empty;
    }
    operator bool() const { return minSplits < 0 || (int)size() >= minSplits; }

    operator std::vector<std::string>() const
    {
        std::vector<std::string> result;
        std::copy(pointers.begin(), pointers.end(), std::back_inserter(result));
        return result;
    }
};

template <typename T, typename S>
inline StringSplit split(T&& s, S const& delim, int minSplits = -1)
{
    return StringSplit(std::forward<T>(s), delim, minSplits);
}

template <size_t... Is>
auto gen_tuple_impl(const StringSplit& ss, std::index_sequence<Is...>)
{
    return std::make_tuple(ss.getString(Is)...);
}

template <size_t N> auto gen_tuple(const StringSplit& ss)
{
    return gen_tuple_impl(ss, std::make_index_sequence<N>{});
}

template <size_t N, typename T>
auto splitn(const std::string& text, const T& sep)
{
    return gen_tuple<N>(split(text, sep));
}

template <typename T> std::pair<T, T> split2(const T& text, const T& sep)
{
    auto it = std::search(begin(text), end(text), begin(sep), end(sep));
    if (it == end(text))
        return std::make_pair(text, T());
    auto it2 = it;
    std::advance(it2, std::distance(begin(sep), end(sep)));
    return std::make_pair(T(begin(text), it), std::string(it2, end(text)));
}

struct URL
{
    std::string protocol;
    std::string hostname;
    int port = -1;
    std::string path;
};

inline URL parse_url(std::string const& input)
{
    URL url;
    std::vector<std::string> parts = split(input, "://");

    if(parts.size() != 2)
        throw std::exception();

    url.protocol = parts[0];

    auto slash = parts[1].find_first_of('/');
    if(slash == std::string::npos) {
        url.hostname = parts[1];
        return url;
    }
    url.path = parts[1].substr(slash+1);
    url.hostname = parts[1].substr(0, slash);

    auto colon = url.hostname.find_last_of(':');
    if(colon != std::string::npos) {
        url.port = std::atoi(url.hostname.substr(colon+1).c_str());
        url.hostname = url.hostname.substr(0, colon);
    }

    return url;

}   


} // namespace utils
