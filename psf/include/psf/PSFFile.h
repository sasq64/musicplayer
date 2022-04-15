#pragma once

#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/utils.h>

#include <cstdint>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <string>
#include <unordered_map>
#include <vector>

namespace fs = std::filesystem;

template <typename T> T read(std::ifstream& s)
{
    T t{};
    s.read(reinterpret_cast<char*>(&t), sizeof(T));
    return t;
}

class PSFFile
{
public:
    explicit PSFFile(fs::path const& name)
    {
        std::ifstream f(name, std::ios::in | std::ios::binary);
        auto fileSize = fs::file_size(name);
        std::array<char, 6> header;
        f.read(header.data(), 4);

        if (memcmp(header.data(), "PSF", 3) == 0) {

            LOGD("PSF VERSION {}", header[3]);

            auto resLen = read<uint32_t>(f);
            auto comprLen = read<uint32_t>(f);

            auto tagOffset = resLen + comprLen + 16;
            if (tagOffset > fileSize - 5) {
                return;
            }

            f.seekg(tagOffset);
            f.read(header.data(), 5);
            header[5] = 0;

            if (memcmp(header.data(), "[TAG]", 5) == 0) {
                auto tagSize = fileSize - comprLen - resLen - 21;
                std::vector<char> data(tagSize);
                f.read(&data[0], tagSize);
                tagData = std::string(&data[0], tagSize);

                auto lines = utils::split(tagData, "\n");
                for (const auto& l : lines) {
                    auto parts = utils::split(l, '=');
                    if (parts.size() == 2) {
                        _tags[utils::toLower(parts[0])] = parts[1];
                    }
                }
            }
        }
        f.close();
    }

    bool valid() { return !tagData.empty(); }

    int songLength()
    {
        auto slen = _tags["length"];
        std::vector<std::string> p = utils::split(slen, ":");
        int seconds = -1;
        if (p.size() == 2) {
            seconds = stol(p[0]) * 60 + stol(p[1]);
        }
        return seconds;
    }

    std::string getTagData() const { return tagData; }

    std::unordered_map<std::string, std::string>& tags() { return _tags; }

private:
    std::string tagData;
    std::unordered_map<std::string, std::string> _tags;
};

