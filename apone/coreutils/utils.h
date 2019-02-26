#pragma once

//#include "vec.h"

#include <atomic>
#include <cstddef>
#include <cstdio>
#include <cstring>
#include <functional>
#include <initializer_list>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <stdint.h>
#include <string>
#include <sys/stat.h>
#include <type_traits>
#include <typeinfo>
#include <utility>
#include <vector>

#ifdef USE_EXFS
#include <experimental/filesystem>
namespace fs = std::experimental::filesystem;
#endif

#include <cmath>
#ifndef M_PI
#    define M_PI 3.14159265358979323846
#endif

namespace utils {

void listRecursive(const std::string& dirName,
			   const std::function<void(const std::string& path)>& f);

const char path_separator = '/';

std::string utf8_encode(const std::string& s);
std::string utf8_encode(const std::wstring& s);
std::wstring utf8_decode(const std::string& s);
int utf8_decode(const std::string& utf8, uint32_t* target);

#if 0
template <typename T, size_t... Is>
auto gen_tuple_impl(const std::vector<T>& v, std::index_sequence<Is...>)
    -> decltype(std::make_tuple(v[Is]...)) {
    return std::make_tuple(v[Is]...);
}

template <size_t N, typename T>
auto gen_tuple(const std::vector<T>& v)
    -> decltype(gen_tuple_impl(v, std::make_index_sequence<N>{})) {
    return gen_tuple_impl(v, std::make_index_sequence<N>{});
}

template <typename T>
std::vector<T> split(const T& s, const T& delim = T(" "), size_t limit = 0) {
    std::vector<T> args;
    auto l = delim.length();
    if(l == 0)
        return args;
    int pos = 0;
    bool crlf = (delim.size() == 1 && delim[0] == 10);
    while(true) {
        auto newpos = s.find(delim, pos);
        if((limit && args.size() == limit) || newpos == std::string::npos) {
            args.push_back(s.substr(pos));
            break;
        }
        if(crlf && newpos > 0 && s[newpos - 1] == 0x0d)
            args.push_back(s.substr(pos, newpos - pos - 1));
        else
            args.push_back(s.substr(pos, newpos - pos));
        pos = newpos + l;
    }

    return args;
}
template <typename T>
std::vector<T> split(const T& s, const char* delim, int limit = 0) {
    return split(s, std::string(delim), limit);
}

template <size_t N>
auto splitn(const std::string& text, const std::string& sep)
    -> decltype(gen_tuple<N>(std::vector<std::string>())) {
    return gen_tuple<N>(split(text, sep));
}

// template <typename ... ARGS> std::tuple<ARGS ...> split(const std::string
// &text,

template <template <typename, typename> class Container, class V, class A>
V join(const Container<V, A>& strings, const V& separator) {
    V out;
    bool first = true;
    for(const auto& s : strings) {
        out += (first ? s : separator + s);
        first = false;
    }
    return out;
}

template <template <typename, typename> class Container, class V, class A>
V join(const Container<V, A>& strings, const wchar_t* separator) {
    return join(strings, V(separator));
}

template <template <typename, typename> class Container, class V, class A>
V join(const Container<V, A>& strings, const char* separator) {
    return join(strings, V(separator));
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
    return join(v, sep);
}
#endif 

void replace_char(std::string& s, char c, char r);
void replace_char(char* s, char c, char r);

std::string urlencode(const std::string& s, const std::string& chars);
std::string urldecode(const std::string& s, const std::string& chars = "");

std::string htmldecode(const std::string& source, bool stripTags = false);
std::wstring jis2unicode(uint8_t* text);

void sleepms(unsigned ms);
void sleepus(unsigned us);
uint64_t getms();
uint64_t getus();
void makedir(const std::string& name);
void makedirs(const std::string& name);

bool endsWith(const std::string& name, const std::string& ext);
bool startsWith(const std::string& name, const std::string& pref);
// bool contains(const std::string &haystack, const std::string &needle);
void makeLower(std::string& s);
std::string toLower(const std::string& s);

std::string rstrip(const std::string& x, char c = ' ');
std::string lstrip(const std::string& x, char c = ' ');
std::string lrstrip(const std::string& x, char c = ' ');
// std::string wordwrap( std::string str, size_t width);
std::vector<std::string> text_wrap(const std::string& text, int width,
                                   int initialWidth = -1);

std::string path_basename(const std::string& name);
std::string path_directory(const std::string& name);
std::string path_filename(const std::string& name);
std::string path_extension(const std::string& name);
std::string path_suffix(const std::string& name);
std::string path_prefix(const std::string& name);

std::string current_exe_path();

bool isalpha(const std::string& s);

float clamp(float x, float a0 = 0.0, float a1 = 1.0);

#ifdef _WIN32
typedef void* HANDLE;
#endif

struct ExecPipe {
    ExecPipe() {}
    ExecPipe(const std::string& cmd);
    ~ExecPipe();

    ExecPipe(ExecPipe&& other) = default;
    ExecPipe(const ExecPipe& other) = delete;
    ExecPipe& operator=(const ExecPipe& other) = delete;
    ExecPipe& operator=(ExecPipe&& other) noexcept;

    bool hasEnded();
    void Kill();
    int read(uint8_t* target, int size);
    int write(uint8_t* source, int size);
    operator std::string();

#ifdef _WIN32
    HANDLE hPipeRead;
    HANDLE hPipeWrite;
    HANDLE hProcess;
#else
    pid_t pid = -1;
    int outfd;
    int infd;
#endif
};

inline ExecPipe execPipe(const std::string& cmd) {
    return ExecPipe(cmd);
}

int shellExec(const std::string& cmd, const std::string& binDir = "");

uint32_t crc32(const uint32_t* data, int size);
uint32_t crc32_area(const uint32_t* data, int width, int height, int pitch);

void schedule_callback(const std::function<void()>& f);
void perform_callbacks();

// SLICE

template <class InputIterator> class slice {
public:
    slice(InputIterator start, InputIterator stop) : start(start), stop(stop) {}

    InputIterator begin() const { return start; }

    InputIterator end() const {
        return stop;
        // return const_iterator(*this, end);
    }

private:
    InputIterator start;
    InputIterator stop;
};

template <class T>
slice<typename T::const_iterator> make_slice(T& vec, int start, int len) {
    return slice<typename T::const_iterator>(vec.begin() + start,
                                             vec.begin() + start + len);
}

template <typename T> struct _ct {

    _ct(const T& to) : to(to) {}
    T to;

    struct const_iterator {
        const_iterator(const T& index) : index(index) {}
        const_iterator(const const_iterator& rhs) : index(rhs.index) {}

        bool operator!=(const const_iterator& other) const {
            return index != other.index;
        }

        int32_t operator*() const { return index; }

        const const_iterator& operator++() {
            index++;
            return *this;
        }
        T index;
    };

    const_iterator begin() const { return const_iterator(0); }
    const_iterator end() const { return const_iterator(to); }
};

template <typename T> struct _cf {

    _cf(const T& from) : from(from) {}
    T from;

    struct const_iterator {
        const_iterator(const T& index) : index(index) {}
        const_iterator(const const_iterator& rhs) : index(rhs.index) {}

        bool operator!=(const const_iterator& other) const {
            return index != other.index;
        }

        T operator*() const { return index; }

        const const_iterator& operator++() {
            index--;
            return *this;
        }
        T index;
    };

    const_iterator begin() const { return const_iterator(from - 1); }
    const_iterator end() const { return const_iterator(-1); }
};

template <typename T> _ct<T> count_to(const T& t) {
    return _ct<T>(t);
}
template <typename T> _cf<T> count_from(const T& f) {
    return _cf<T>(f);
}
// Wrap an object with a name to use where sorting is needed etc
template <typename T> struct Named {
    Named() {}
    Named(const std::string& name, const T& obj) : name(name), obj(obj) {}

    operator T&() { return obj; }
    bool operator==(const char* n) const {
        return strcmp(name.c_str(), n) == 0;
    }
    bool operator==(const std::string& n) const { return name == n; }
    bool operator<(const Named& other) const { return name < other.name; }

private:
    std::string name;
    T obj;
};

#ifdef USE_EXFS

inline void _listFiles(const std::string& dirName,
                const std::function<void(const std::string& path)>& f)
{
    for (const auto& p : fs::directory_iterator(dirName)) {
        auto&& path = p.path().string();
        if (path[0] == '.' &&
            (path[1] == 0 || (path[1] == '.' && path[2] == 0)))
            continue;
        if (fs::is_directory(p.status()))
            _listFiles(path, f);
        else
            f(path);
    }
}

inline void listFiles(const std::string& dirName,
               const std::function<void(const std::string& path)>& f)
{
    if (!fs::is_directory(dirName)) {
        f(dirName);
        return;
    }
    _listFiles(dirName, f);
}
#endif

} // namespace utils
