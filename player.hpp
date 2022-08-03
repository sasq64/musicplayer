#pragma once

#include <coreutils/utils.h>

#include <filesystem>
#include <memory>
#include <optional>
#include <variant>
#include <vector>

using Meta = std::variant<std::string, double, uint32_t>;

struct MusicPlayer
{
    static inline std::filesystem::path findDataPath(std::string const& file = "")
    {
        namespace fs = std::filesystem;
        auto xd = utils::get_exe_dir();
        auto home = utils::get_home_dir();
        auto searchPath = std::vector{fs::absolute(xd / "data"),
                                      fs::absolute(xd / ".." / "data"),
                                      fs::absolute(xd / ".." / ".." / "data"),
                                      home / ".local" / "share" / "musix",
                                      home / ".config" / "musix",
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

    virtual ~MusicPlayer() = default;
    static std::unique_ptr<MusicPlayer> create();
static std::unique_ptr<MusicPlayer> createWriter();
    virtual void update() {}
    virtual void clear() {}
    virtual void play(std::filesystem::path const& fileName) {}

    virtual void next() {}
    virtual void set_song(int song) {}

    virtual void detach() {}

    using Info = std::pair<std::string, Meta>;

    virtual std::vector<Info> get_info() { return {}; }
};

