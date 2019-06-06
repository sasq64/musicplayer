#pragma once

#include <coreutils/file.h>
#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/utils.h>

#include <cstdint>
#include <cstring>
#include <string>
#include <unordered_map>
#include <vector>

class PSFFile
{
public:
    PSFFile(const std::string& name)
    {
        utils::File f{name};

        int fileSize = (int)f.getSize();

        uint8_t header[6];

        f.read(header, 4);
        if (memcmp(header, "PSF", 3) == 0) {

            LOGD("PSF VERSION %d", header[3]);

            int resLen = f.read<uint32_t>();
            int comprLen = f.read<uint32_t>();

            int tagOffset = resLen + comprLen + 16;
            if (tagOffset > fileSize - 5)
                return;

            f.seek(tagOffset);
            f.read(header, 5);
            header[5] = 0;
            LOGD("HEADER %s", header);

            if (memcmp(header, "[TAG]", 5) == 0) {
                int tagSize = fileSize - comprLen - resLen - 21;
                std::vector<char> data(tagSize);
                f.read(&data[0], tagSize);
                tagData = std::string(&data[0], tagSize);

                auto lines = utils::split(tagData, "\n");
                for (const auto& l : lines) {
                    auto parts = utils::split(l, '=');
                    if (parts.size() == 2)
                        _tags[utils::toLower(parts[0])] = parts[1];
                }

                LOGD("%s", tagData);
            }
        }
        f.close();
    }

    bool valid() { return tagData.size() > 0; }

    int songLength()
    {
        auto slen = _tags["length"];
        std::vector<std::string> p = utils::split(slen, ":");
        int seconds = -1;
        if (p.size() == 2)
            seconds = stol(p[0]) * 60 + stol(p[1]);
        return seconds;
    }

    std::string getTagData() const { return tagData; }

    std::unordered_map<std::string, std::string>& tags() { return _tags; }

private:
    std::string tagData;
    std::unordered_map<std::string, std::string> _tags;
};

