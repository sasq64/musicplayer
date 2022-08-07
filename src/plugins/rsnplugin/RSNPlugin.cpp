#include "RSNPlugin.h"

#include <archive/archive.h>
#include <coreutils/log.h>

#include <memory>
#include <set>

namespace musix {

class RSNPlayer : public ChipPlayer
{
public:
    RSNPlayer(const std::vector<std::string>& l,
              const std::shared_ptr<ChipPlugin>& plugin)
        : songs(l), plugin(plugin)
    {
        LOGD("Playing with {}", plugin->name());
        player = std::shared_ptr<ChipPlayer>(plugin->fromFile(l[0]));
        if (player == nullptr) { throw player_exception(); }
        setMeta("title", player->meta("title"), "sub_title",
                player->meta("sub_title"), "game", player->meta("game"),
                "composer", player->meta("composer"), "length",
                player->meta("length"), "format", player->meta("format"),
                "songs", l.size());
    }

    int getSamples(int16_t* target, int noSamples) override
    {
        if (player) { return player->getSamples(target, noSamples); }
        return 0;
    }

    bool seekTo(int song, int seconds) override
    {
        player = nullptr;
        player = std::shared_ptr<ChipPlayer>(plugin->fromFile(songs[song]));
        if (player) {
            setMeta("sub_title", player->meta("sub_title"), "length",
                    player->meta("length"), "song", song);
            if (seconds > 0) { player->seekTo(-1, seconds); }
            return true;
        }
        return false;
    }

private:
    std::vector<std::string> songs;
    std::shared_ptr<ChipPlayer> player;
    std::shared_ptr<ChipPlugin> plugin;
};

ChipPlayer* RSNPlugin::fromFile(const std::string& fileName)
{

    static const std::set<std::string> song_formats{
        "spc", "psf",     "minipsf", "psf2",    "minipsf2", "miniusf",
        "dsf", "minidsf", "mini2sf", "minigsf", "mdx",      "s98"};

    std::vector<std::string> l;
    auto rsnDir = utils::get_cache_dir("chipmusic") / ".rsn";
    fs::create_directory(rsnDir);
    for (auto const& f : utils::listFiles(rsnDir, false, true)) {
        fs::remove(f);
    }

    if (!fs::exists(fileName)) { return nullptr; }

    try {
        auto* a = utils::Archive::open(fileName, rsnDir.string(),
                                       utils::Archive::TYPE_RAR);
        a->extractAll(rsnDir.string());
        for (auto const& f : utils::listFiles(rsnDir, false, true)) {
            if (song_formats.count(utils::path_extension(f.string())) > 0) {
                LOGD("Found {}", f.string());
                l.push_back(f.string());
            }
        };
        delete a;
    } catch (utils::archive_exception& e) {
        LOGW("Archive fail");
        return nullptr;
    }

    sort(l.begin(), l.end());

    if (!l.empty()) {
        for (auto name : l) {
            utils::makeLower(name);
            for (auto const& plugin : ChipPlugin::getPlugins()) {
                if (plugin->name() != "UADE" && plugin->name() != "RSNPlugin" &&
                    plugin->canHandle(name)) {
                    try {
                        return new RSNPlayer(l, plugin);
                    } catch (player_exception& e) {
                        LOGD("FAILED");
                    }
                }
            }
        }
    }
    return nullptr;
};

bool RSNPlugin::canHandle(const std::string& name)
{
    static const std::set<std::string> supported_ext{"rsn", "rps", "rdc",
                                                     "rds", "rgs", "r64"};
    return supported_ext.count(utils::path_extension(name)) > 0;
}

} // namespace musix
