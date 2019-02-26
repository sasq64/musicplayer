#include "catch.hpp"

//#include "src/modutils.h"
#include "chipplugin.h"
#include "plugins/plugins.h"

#include <coreutils/log.h>
#include <coreutils/file.h>
#include <string>
#include <array>
#include <numeric>

template <typename PLUGIN, typename... ARGS>
int testPlugin(std::string const& dir, std::string const& exclude, const ARGS&... args)
{
    std::array<int16_t, 8192> buffer;
    PLUGIN plugin{args...};
    printf("---- %s ----\n", plugin.name().c_str());
    logging::setLevel(logging::Level::Warning);
    int total = 0;
    int working = 0;
    for (auto f : utils::File{dir}.listFiles()) {
        if(exclude != "" && f.getName().find(exclude) != std::string::npos)
            continue;

        int64_t sum = 0;
        printf("Trying %s\n", f.getName().c_str());
        auto* player = plugin.fromFile(f.getName());
        if (player) {
            //puts("Player created");
            int count = 15;
            while (sum == 0 && count != 0) {
                int rc = player->getSamples(&buffer[0], buffer.size());
                // REQUIRE(rc > 0);
                if (rc > 0) {
                    sum = std::accumulate((uint16_t*)&buffer[0], (uint16_t*)&buffer[rc], (int64_t)0);
                    // REQUIRE(sum != 0);
                    if (sum > 0) {
                        break;
                    }
                    count--;
                } else
                    break;
            }
            delete player;
        }

        bool madeSound = (sum > 0);

        if(madeSound) working++;
        total++;

        printf("#### Playing %s : %s\n", f.getName().c_str(), 
                player ?
                (madeSound ? "OK" : "NO SOUND")
                : "FAILED"
                );
    }
    int percent = working * 100 / total;
    printf("PERCENT %d\n\n", percent);
    return percent;
}

TEST_CASE("all", "[music]")
{
}


TEST_CASE("gme", "[music]")
{
    REQUIRE(testPlugin<musix::GMEPlugin>("testmus/gme/working", "") == 100);
    REQUIRE(testPlugin<musix::GMEPlugin>("testmus/gme/nowork", "") == 0);
}

TEST_CASE("adlib", "[music]")
{
    testPlugin<musix::AdPlugin>("testmus/adlib", "", "data");
}

TEST_CASE("uade", "[music]")
{
    testPlugin<musix::UADEPlugin>("testmus/uade", "smp", "data");
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
    testPlugin<musix::HEPlugin>("testmus/psx", "lib", "data/hebios.bin");
}

TEST_CASE("zx", "[music]")
{
    testPlugin<musix::AyflyPlugin>("testmus/zx", "");
}

