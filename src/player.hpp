#pragma once

#include <coreutils/utils.h>

#include <fmt/format.h>

#include <filesystem>
#include <memory>
#include <optional>
#include <variant>
#include <vector>

using Meta = std::variant<std::string, double, uint32_t>;

struct MusicPlayer
{
    static inline std::filesystem::path
    findDataPath(std::string const& file = "")
    {
        namespace fs = std::filesystem;
        auto xd = utils::get_exe_dir();
        auto home = utils::get_home_dir();
        auto searchPath = std::vector{fs::absolute(xd / "data"),
                                      fs::absolute(xd / ".." / "data"),
                                      fs::absolute(xd / ".." / ".." / "data"),
                                      home / ".local" / "share" / "musix",
                                      fs::path("/usr/share/musix"),
                                      fs::path("/usr/local/share/musix")};
        fs::path dataPath;
        for (auto&& p : searchPath) {
            if (file.empty() ? fs::exists(p) : fs::exists(p / file)) {
                dataPath = p;
                break;
            }
        }
        return file.empty() ? dataPath : dataPath / file;
    }

    template <typename T> void log(T&& t)
    {
        fmt::print(std::forward<T>(t));
        puts("");
        fflush(stdout);
    }

    template <typename T, typename... A> void log(T&& t, A&&... args)
    {
        fmt::print(std::forward<T>(t), std::forward<A>(args)...);
        puts("");
        fflush(stdout);
    }

    virtual ~MusicPlayer() = default;

    enum class Type
    {
        Basic,
        Piped,
        Writer
    };

    static std::unique_ptr<MusicPlayer> create(Type pt);

    virtual void update() {}
    virtual void clear() {}
    virtual void add(std::filesystem::path const& fileName) {}

    virtual void next() {}
    virtual void prev() {}
    virtual void set_song(int song) {}

    virtual void detach() {}

    using Info = std::pair<std::string, Meta>;

    virtual std::vector<Info> get_info() { return {}; }
};

