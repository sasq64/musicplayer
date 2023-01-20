#pragma once

#include <cstring>
#include <string>

//  #include <fmt/format.h>

namespace logging {

enum Level
{
    Verbose = 0,
    Debug = 1,
    Info = 2,
    Warning = 3,
    Error = 4,
    Off = 100
};

void log(const std::string& text);
void log( Level level, const std::string& text);
void log2(const char* fn, int line,  Level level, const std::string& text);

template <class... A> void log(const std::string& fmt, const A&... args)
{
    //log(fmt::format(fmt, args...));
}

template <class... A>
void log(Level level, const std::string& fmt, const A&... args)
{
    //log(level, fmt::format(fmt, args...));
}

template <class... A>
void log2(const char* fn, int line, Level level, const std::string& fmt,
          const A&... args)
{
    //log2(fn, line, level, fmt::format(fmt, args...));
}

void setLevel(Level level);
void setOutputFile(const std::string& fileName);

inline constexpr const char* xbasename(const char* x)
{
    const char* slash = x;
    while (*x != 0) {
        if (*x++ == '/') { slash = x; }
    }
    return slash;
}

#ifdef COREUTILS_LOGGING_DISABLE

#    define LOGV(...)
#    define LOGD(...)
#    define LOGI(...)
#    define LOGW(...)
#    define LOGE(...)

#else

#    define LOGV(...)                                                          \
        logging::log2(logging::xbasename(__FILE__), __LINE__,                  \
                      logging::Verbose, __VA_ARGS__)
#    define LOGD(...)                                                          \
        logging::log2(logging::xbasename(__FILE__), __LINE__, logging::Debug,  \
                      __VA_ARGS__)
#    define LOGI(...)                                                          \
        logging::log2(logging::xbasename(__FILE__), __LINE__, logging::Info,   \
                      __VA_ARGS__)
#    define LOGW(...)                                                          \
        logging::log2(logging::xbasename(__FILE__), __LINE__,                  \
                      logging::Warning, __VA_ARGS__)
#    define LOGE(...)                                                          \
        logging::log2(logging::xbasename(__FILE__), __LINE__, logging::Error,  \
                      __VA_ARGS__)
#endif
} // namespace logging

