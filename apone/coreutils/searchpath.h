#pragma once

#include "utils.h"
#include "split.h"

#include <optional>
#include <string>
#include <vector>

//#include <experimental/filesystem>
// namespace fs = std::experimental::filesystem;

inline std::string makeSearchPath(std::vector<utils::path> paths, bool resolve)
{
    std::string searchPath = "";
    std::string sep = "";
    for (const auto& p : paths) {
        if (!resolve || utils::exists(p)) {
            searchPath =
                searchPath + sep + p.string();
            sep = ";";
        }
    }
    return searchPath;
}

inline std::optional<utils::path> findFile(const std::string& searchPath,
                                           const std::string& name)
{
    // LOGD("Find '%s'", name);
    if (name == "")
        return {};
    auto parts = utils::split(searchPath, ";");
    for (utils::path p : parts) {
        if (!p.empty()) {
            // LOGD("...in path %s", p);
            utils::path f{p / name};
            if (utils::exists(f))
                return f;
        }
    }
    return {};
}
