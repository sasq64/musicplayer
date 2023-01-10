
#include "chipplayer.h"
#include "chipplugin.h"

#include <pybind11/detail/common.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl/filesystem.h>

#include <cctype>
#include <chrono>
#include <filesystem>
#include <thread>

namespace fs = std::filesystem;
namespace py = pybind11;

using namespace pybind11::literals; // NOLINT




void init()
{
    musix::ChipPlugin::createPlugins("data");
    //auto atexit = py::module_::import("atexit");
    //atexit.attr("register")(py::cpp_function([] {
    //}));
}

std::shared_ptr<musix::ChipPlayer> load_music(std::string const& name)
{
    std::shared_ptr<musix::ChipPlayer> player;
    for (const auto& plugin : musix::ChipPlugin::getPlugins()) {
        if (plugin->canHandle(name)) {
            if (auto* ptr = plugin->fromFile(name)) {
                player = std::shared_ptr<musix::ChipPlayer>(ptr);
                break;
            }
        }
    }
    if (!player) {
        throw musix::player_exception("No plugin could handle file");
    }
    return player;
}


PYBIND11_MODULE(_musix, mod)
{
    mod.doc() = "";

    py::class_<musix::ChipPlayer>(mod, "Player")
        .def("render", &musix::ChipPlayer::getSamples);

    mod.def("init", &init, "Init musix");
    mod.def("load", &load_music, "name"_a, "Load music");

}

