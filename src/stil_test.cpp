#include "catch.hpp"

#include "chipplugin.h"
#include "plugins/plugins.h"

#include "stil/STIL.hpp"

#include <array>
#include <coreutils/log.h>
#include <coreutils/utils.h>
#include <filesystem>
#include <numeric>
#include <string>
namespace fs = std::filesystem;

static fs::path findProjectDir()
{
    auto current = fs::absolute(".");

    while (!current.empty()) {
        if (fs::exists(current / "testmus")) { return current; }
        current = current.parent_path();
    }
    return {};
}

inline fs::path projDir()
{
    static fs::path projectDir = findProjectDir();
    return projectDir;
}

TEST_CASE("stil", "[stil]")
{
    static auto dataDir = projDir() / "data";

    STIL stil{dataDir};

    for (auto const& f : utils::listFiles(projDir() / "music" / "C64" , false, false)) {
        auto data = utils::read_file(f);
        auto info = stil.getInfo(data);
        fmt::print("{} by {}\n'{}'\n", info.title, info.composer, info.comment);
        for(auto&& song : info.songs) {
            fmt::print("  {} / {} ({}) -- {} {}\n", song.title, song.artist, song.comment, song.seconds, song.subSong);
        }
    }
}
