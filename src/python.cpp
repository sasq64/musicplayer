
#include "chipplayer.h"
#include "chipplugin.h"

#include <pybind11/detail/common.h>
#include <pybind11/pybind11.h>
#include <pybind11/functional.h>
#include <pybind11/stl.h>

#include <cctype>
#include <chrono>
#include <filesystem>
#include <thread>

namespace py = pybind11;
namespace fs = std::filesystem;
using namespace pybind11::literals; // NOLINT

py::object get_samples(musix::ChipPlayer& player, size_t size)
{
    auto* bytes = static_cast<PyBytesObject*>(
        PyObject_Malloc(offsetof(PyBytesObject, ob_sval) + size * 2));
    PyObject_INIT_VAR(bytes, &PyBytes_Type, size * 2);
    bytes->ob_shash = -1;
    auto sz = player.getSamples(reinterpret_cast<int16_t*>(&bytes->ob_sval),
                                static_cast<int>(size));
    if (sz == 0) { return py::cast(nullptr); }
    if (sz < 0) {
        throw musix::player_exception("Could not render samples from song.");
    }
    return py::reinterpret_steal<py::object>(
        reinterpret_cast<PyObject*>(bytes));
}

fs::path getModulePath()
{
    py::gil_scoped_acquire const acquire;
    auto const example = py::module::import("musix");
    return {example.attr("__file__").cast<std::string>()};
}

void init()
{
    auto p = getModulePath();
    auto data_dir = (p.parent_path() / "data");
    musix::ChipPlugin::createPlugins(data_dir.string());
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

    py::class_<musix::ChipPlayer, std::shared_ptr<musix::ChipPlayer>>(mod,
                                                                      "Player")
        .def("render", &get_samples, "count"_a,
             "Generate `count` number of samples and return `count*2` bytes")
        .def("get_meta", &musix::ChipPlayer::meta, "name"_a,
             "Get meta data about the loaded song.")
        .def("seek", &musix::ChipPlayer::seekTo, "song"_a, "seconds"_a = -1)
        .def("on_meta", &musix::ChipPlayer::onMeta);

    mod.def("init", &init, "Init musix");
    mod.def("load", &load_music, "name"_a, "Load music file");
}

