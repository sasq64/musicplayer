#include "songfile_identifier.h"

#include "modutils.h"

#include <archive/archive.h>
#include <coreutils/log.h>
#include <coreutils/split.h>
#include <coreutils/text.h>
#include <coreutils/utf8.h>
#include <coreutils/utils.h>

#ifdef WITH_MPG123
#    include <mpg123.h>
#endif

#include <algorithm>
#include <memory>
#include <string>

using namespace std::string_literals;

static std::string get_string(uint8_t* ptr, int64_t size)
{
    auto *end = ptr;
    while (*end != 0 && end - ptr < size) {
        end++;
    }
    return std::string((const char*)ptr, end - ptr); //NOLINT
}

template <typename T> T get(const std::vector<uint8_t>&, int64_t) {}

template <typename T> T get_le(const std::vector<uint8_t>&, int64_t) {}

template <> uint16_t get(const std::vector<uint8_t>& v, int64_t offset)
{
    return static_cast<unsigned>(v[offset] << 8U) | v[offset + 1];
}

template <> uint32_t get(const std::vector<uint8_t>& v, int64_t offset)
{
    return (static_cast<unsigned>(v[offset + 0]) << 24U) |
        static_cast<unsigned>(v[offset + 1] << 16U) |
        static_cast<unsigned>(v[offset + 2] << 8U) | v[offset + 3];
}

template <> uint32_t get_le(const std::vector<uint8_t>& v, int64_t offset)
{
    return (static_cast<unsigned>(v[offset + 3]) << 24U) |
        static_cast<unsigned>(v[offset + 2] << 16U) |
        static_cast<unsigned>(v[offset + 1] << 8U) | v[offset + 0];
}

template <> uint64_t get(const std::vector<uint8_t>& v, int64_t offset)
{
    return (static_cast<uint64_t>(get<uint32_t>(v, offset)) << 32U) |
        get<uint32_t>(v, offset + 4);
}

std::vector<std::string> getLines(std::string const& text)
{
    std::vector<std::string> lines;

    std::array<char, 256> tmp; // NOLINT
    char* t = tmp.data();
    const char* ptr = text.c_str();
    bool eol = false;
    while (*ptr != 0) {
        if (t - tmp.data() >= 255) { break; }

        while (*ptr == 10 || *ptr == 13) {
            ptr++;
            eol = true;
        }
        if (eol) {
            *t = 0;
            t = tmp.data();
            lines.emplace_back(t);
            eol = false;
        }
        *t++ = *ptr++;
    }

    *t = 0;
    t = tmp.data();
    if (strlen(t) > 0) { lines.emplace_back(tmp.data()); }

    return lines;
}

bool parseSid(SongInfo& info)
{
    auto buffer = utils::read_file(info.path, 0xd8);
    info.format = "Commodore 64";
    info.title = utils::utf8_encode(get_string(&buffer[0x16], 0x20));
    info.composer = utils::utf8_encode(get_string(&buffer[0x36], 0x20));
    // auto copyright = std::string((const char*)&buffer[0x56], 0x20);
    return true;
}

bool parseSap(SongInfo& info)
{
    auto data = utils::read_file(info.path);

    auto end_of_header = search_n(data.begin(), data.end(), 2, 0xff);
    auto header = std::string(data.begin(), end_of_header);
    auto lines = getLines(header);

    if (lines.empty() || lines[0] != "SAP") { return false; }

    for (const auto& l : lines) {
        if (utils::startsWith(l, "AUTHOR")) {
            info.composer = utils::lrstrip(l.substr(7), '\"');
        } else if (utils::startsWith(l, "NAME")) {
            info.title = utils::lrstrip(l.substr(5), '\"');
        }
    }

    info.format = "Atari 8Bit";

    return true;
}

extern "C"
{
    int unice68_depacker(void* dest, const void* src);
    int unice68_get_depacked_size(const void* buffer, int* p_csize);
}

bool parseSndh(SongInfo& info)
{
    std::unique_ptr<uint8_t[]> unpackPtr;
    LOGD("SNDH >%s", info.path);
    auto data = utils::read_file(info.path);
    if (data.size() < 32) { return false; }
    auto* ptr = data.data();
    auto head = get_string(ptr, 4);
    if (head == "ICE!") {
        int dsize = unice68_get_depacked_size(ptr, nullptr);
        LOGD("Unicing %d bytes to %d bytes", data.size(), dsize);
        unpackPtr = std::make_unique<uint8_t[]>(dsize);
        int res = unice68_depacker(unpackPtr.get(), ptr);
        if (res == 0) ptr = unpackPtr.get();
    }

    auto id = get_string(ptr + 12, 4);

    if (id == "SNDH") {

        info.format = "Atari ST";

        // LOGD("SNDH FILE");
        int count = 10;
        int got = 0;
        ptr += 16;
        std::string arg;
        std::string tag = get_string(ptr, 4);
        // LOGD("TAG %s", tag);
        while (tag != "HDNS") {
            if (count-- == 0) break;
            uint8_t* p = ptr;
            if (tag == "#!SN" || tag == "TIME") {
                ptr += 12;
            } else {
                while (*ptr)
                    ptr++;
                while (!(*ptr))
                    ptr++;
            }
            if (tag == "TITL") {
                got |= 1;
                info.title = get_string(p + 4, 256);
            } else if (tag == "COMM") {
                got |= 2;
                info.composer = get_string(p + 4, 256);
            }
            if (got == 3) break;
            tag = get_string(ptr, 4);
            // LOGD("TAG %s", tag);
        }
        LOGD("%s - %s", info.title, info.composer);
        return true;
    }
    return false;
}

bool parseSnes(SongInfo& info)
{
    //static std::vector<uint8_t> buffer(0xd8);
    info.format = "Super Nintendo";

    auto outDir = utils::get_cache_dir(".rsntemp");
    auto* a = utils::Archive::open(info.path, outDir.string(),
                                   utils::Archive::TYPE_RAR);
    bool done = false;
    for(int i=0; i<a->totalFiles(); i++) {
        if (done) { continue; }
        auto s = a->nameFromPosition(i);
        // LOGD("FILE %s", s);
        if (utils::path_extension(s) == "spc") {
            a->extract(s);
            auto buffer = utils::read_file(outDir / s);
            if (buffer[0x23] == 0x1a) {
                auto game = get_string(&buffer[0x4e], 0x20);
                auto composer = get_string(&buffer[0xb1], 0x20);

                int offs = 0x10200;
                auto id = get_string(&buffer[offs], 4);
                if (id == "xid6") {
                    if (buffer[8 + offs] == 0x2) {
                        int l = buffer[10 + offs];
                        game = std::string((const char*)&buffer[12 + offs], l);
                    } else if (buffer[8 + offs] == 0x3) {
                        int l = buffer[10 + offs];
                        composer = std::string((const char*)&buffer[12 + offs], l);
                    }
                }

                info.composer = composer;
                info.game = game;
                info.title = "";
                done = true;
            }
        }
    }
    delete a;
    return done;
}

bool parseMp3(SongInfo& info)
{
#ifdef WITH_MPG123
    int err = mpg123_init();
    mpg123_handle* mp3 = mpg123_new(NULL, &err);

    if (mpg123_open(mp3, info.path.c_str()) != MPG123_OK) return false;

    mpg123_format_none(mp3);

    mpg123_scan(mp3);
    int meta = mpg123_meta_check(mp3);
    mpg123_id3v1* v1;
    mpg123_id3v2* v2;
    if (meta & MPG123_ID3 && mpg123_id3(mp3, &v1, &v2) == MPG123_OK) {
        if (v2) {
            info.title = htmldecode(v2->title->p);
            info.composer = htmldecode(v2->artist->p);
        } else if (v1) {
            info.title = htmldecode((char*)v2->title);
            info.composer = htmldecode((char*)v2->artist);
        }
    }

    info.format = "MP3";

    if (mp3) {
        mpg123_close(mp3);
        mpg123_delete(mp3);
    }
    mpg123_exit();
    return true;
#else
    (void)info;
    return false;
#endif
}

bool parsePList(SongInfo& info)
{

    //File f{ info.path };

    auto text = utils::read_as_string(info.path);

    info.title = utils::path_basename(info.path);
    info.composer = "";
    info.format = "Playlist";

    auto lines = utils::split(text, '\n');

    for (std::string l : lines) {
        if (l.length() > 0 && l[0] == ';') {
            auto parts = utils::split(l.substr(1), "\t");
            info.title = parts[0];
            if (parts.size() >= 2) {
                info.composer = parts[1];
                info.format = "C64 Demo";
            } else {
                info.format = "C64 Event";
            }
        }
    }
    return true;
}

bool parseNsfe(SongInfo& song)
{
    auto data = utils::read_file(song.path);
    int64_t i = 0;
    auto id = get_string(&data[i], 4);
    i += 4;
    if (id != "NSFE") { return false; }
    while (i < data.size()) {
        auto size = get_le<uint32_t>(data, i);
        i += 4;
        auto tag = get_string(&data[i], 4);
        i += 4;
        auto next = i + size;

        if (tag == "auth") {
            song.game = get_string(&data[i], 32);
            i += (song.game.size()+1);
            song.composer = get_string(&data[i], 32);
            i += (song.composer.size()+1);
            return true;
        }
        i = next;
    }
    return false;
}


static void fixName(std::string& name)
{
    bool capNext = true;
    for (size_t i = 0; i < name.size(); i++) {
        auto& c = name[i];
        if (capNext) {
            c = static_cast<char>(toupper(c));
            capNext = (c == 'I' && name[i + 1] == 'i');
        }
        if (c == '_') {
            capNext = true;
            c = ' ';
        }
    }
}

bool parseTed(SongInfo& info)
{
    auto parts = utils::split(info.metadata[SongInfo::INFO], "/");
    LOGD("PARTS %s", parts);
    auto l = parts.size();
    auto title = utils::path_basename(parts[l - 1]);
    fixName(title);
    std::string composer = "Unknown";
    if (strcmp(parts[0], "musicians") == 0) {
        composer = parts[1];
        std::vector<std::string> cp = utils::split(composer, "_");
        auto cpl = cp.size();
        if (cpl > 1 && cp[0] != "the" && cp[0] != "billy" &&
            cp[0] != "legion") {
            auto t = cp[0];
            cp[0] = cp[cpl - 1];
            cp[cpl - 1] = t;
        }
        for (auto& cpp : cp) {
            cpp[0] = static_cast<char>(toupper(cpp[0]));
        }

        composer = utils::join(cp.begin(), cp.end(), " "s);
    }

    info.format = "TED";
    info.title = title;
    info.composer = composer;

    return true;
}

bool identify_song(SongInfo& info, std::string ext)
{
    if (ext.empty()) { ext = getTypeFromName(info.path); }

    //printf("EXT %s\n", ext.c_str());
    const std::unordered_map<std::string, bool (*)(SongInfo&)> parsers {
        {"nsfe", &parseNsfe},
        {"plist", &parsePList},
        {"rsn", &parseSnes},
        {"sid", &parseSid},
        {"sndh", &parseSndh},
        {"sap", &parseSap},
        {"mp3", &parseMp3},
        {"prg", &parseTed},
    };

    if(auto it = parsers.find(ext); it != parsers.end()) {
        return it->second(info);
    }
    return false;
}
