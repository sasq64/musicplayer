#include "catch.hpp"

#include "chipplugin.h"
#include "plugins/plugins.h"

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

static auto dataDir = projDir() / "data";

template <typename PLUGIN, typename... ARGS>
int testPlugin(std::string const& dir, std::string const& exclude,
               const ARGS&... args)
{
    auto realDir = projDir() / dir;

    std::vector<std::string> ex;
    if (!exclude.empty()) { ex = utils::split(exclude, ";"); }

    std::array<int16_t, 8192> buffer;
    PLUGIN plugin{args...};
    printf("---- %s ----\n", plugin.name().c_str());
    logging::setLevel(logging::Level::Warning);
    int total = 0;
    int working = 0;
    for (auto const& f : utils::listFiles(realDir, false, false)) {
        bool play = true;
        //printf("%s against '%s'\n", f.c_str(), exclude.c_str());
        for (auto const& e : ex) {
            if (f.string().find(e) != std::string::npos) { play = false; }
        }
        //printf("GO %s\n", play ? "PLAY" : "NO");

        if (!play) { continue; }

        int64_t sum = 0;
        //printf("Trying %s\n", f.string().c_str());
        musix::ChipPlayer* player = nullptr;
        try {
            player = plugin.fromFile(f.string());
        } catch (musix::player_exception& pe) {
            printf("Exception %s\n", pe.what());
        }
        if (player) {
            // puts("Player created");
            int count = 15;
            while (sum == 0 && count != 0) {
                int rc = player->getSamples(&buffer[0], buffer.size());
                // REQUIRE(rc > 0);
                if (rc > 0) {
                    sum = std::accumulate(
                        reinterpret_cast<uint16_t*>(&buffer[0]),
                        reinterpret_cast<uint16_t*>(&buffer[rc]),
                        static_cast<int64_t>(0));
                    // REQUIRE(sum != 0);
                    if (sum > 0) { break; }
                    count--;
                } else {
                    break;
                }
            }
            delete player;
        }

        bool madeSound = (sum > 0);

        if (madeSound) { working++; }
        total++;

        printf("#### Playing %s : %s\n", f.string().c_str(),
               player ? (madeSound ? "OK" : "NO SOUND") : "FAILED");
    }
    if (total == 0) { return 100; }
    int percent = working * 100 / total;
    printf("PERCENT %d\n\n", percent);
    return percent;
}

TEST_CASE("all", "[music]") {}

TEST_CASE("gme", "[music]")
{
    REQUIRE(testPlugin<musix::GMEPlugin>("testmus/gme/working", "") == 100);
    REQUIRE(testPlugin<musix::GMEPlugin>("testmus/gme/nowork", "") == 0);
}

TEST_CASE("adlib", "[music]")
{
    REQUIRE(testPlugin<musix::AdPlugin>("testmus/adlib/working", ".dat;.ins",
                                        dataDir) == 100);
    REQUIRE(testPlugin<musix::AdPlugin>("testmus/adlib/nowork", ".dat;.ins",
                                        dataDir) == 0);
}

TEST_CASE("uade", "[music]")
{
    testPlugin<musix::UADEPlugin>("testmus/uade", "smp", dataDir);
}

TEST_CASE("openmpt", "[music]")
{
    testPlugin<musix::OpenMPTPlugin>("testmus/openmpt", "");
}

TEST_CASE("gsf", "[music]")
{
    testPlugin<musix::GSFPlugin>("testmus/gsf", "lib");
}

TEST_CASE("nds", "[music]")
{
    testPlugin<musix::NDSPlugin>("testmus/nds", "lib");
}

TEST_CASE("psx", "[music]")
{
    testPlugin<musix::HEPlugin>("testmus/psx", "lib", dataDir / "hebios.bin");
}

TEST_CASE("zx", "[music]")
{
    testPlugin<musix::AyflyPlugin>("testmus/zx", "");
}

#if 0
TEST_CASE("vicemd5", "[viceplugin]")
{
    //; /MUSICIANS/G/Galway_Martin/Comic_Bakery.sid
    // 8ffecb26d6ff34e3 947abb1b90e1779b=
    // 3:09 0:34 0:50 0:03 0:03 0:12 0:01 0:01 0:02 0:08 0:01 0:01 0:03 0:01
    musix::VicePlugin plugin;
    plugin.setDataDir(projDir() / "data");
    plugin.readLengths();
    auto lengths = musix::VicePlugin::findLengths(0x8ffecb26d6ff34e3);
    REQUIRE(lengths.size() == 14);
    REQUIRE(lengths[0] == 3 * 60 + 9);
    REQUIRE(lengths[1] == 34);

    auto key = musix::VicePlugin::calculateMD5(projDir() / "music" / "C64" /
                                               "Comic_Bakery.sid");
    LOGI("KEY %x", key);

    REQUIRE(key == 0x8ffecb26d6ff34e3);
}
#endif
