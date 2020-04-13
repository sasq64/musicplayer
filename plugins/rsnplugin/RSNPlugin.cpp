#include "RSNPlugin.h"

#include <archive/archive.h>
#include <coreutils/file.h>
#include <coreutils/log.h>
#include <coreutils/path.h>

#include <set>

using namespace std;
using namespace utils;

namespace musix {

class RSNPlayer : public ChipPlayer
{
public:
    RSNPlayer(const vector<string>& l, shared_ptr<ChipPlugin> plugin)
        : songs(l), plugin(plugin)
    {
        LOGD("Playing with %s", plugin->name());
        player = shared_ptr<ChipPlayer>(plugin->fromFile(l[0]));
        if (player == nullptr)
            throw player_exception();
        setMeta("title", player->getMeta("title"), "sub_title",
                player->getMeta("sub_title"), "game", player->getMeta("game"),
                "composer", player->getMeta("composer"), "length",
                player->getMeta("length"), "format", player->getMeta("format"),
                "songs", l.size());
    }

    virtual int getSamples(int16_t* target, int noSamples) override
    {
        if (player)
            return player->getSamples(target, noSamples);
        return 0;
    }

    virtual bool seekTo(int song, int seconds) override
    {
        player = nullptr;
        player = shared_ptr<ChipPlayer>(plugin->fromFile(songs[song]));
        if (player) {
            setMeta("sub_title", player->getMeta("sub_title"), "length",
                    player->getMeta("length"));
            if (seconds > 0)
                player->seekTo(-1, seconds);
            return true;
        }
        return false;
    }

private:
    vector<string> songs;
    shared_ptr<ChipPlayer> player;
    shared_ptr<ChipPlugin> plugin;
};

ChipPlayer* RSNPlugin::fromFile(const string& fileName)
{

    static const set<string> song_formats{
        "spc", "psf",     "minipsf", "psf2",    "minipsf2", "miniusf",
        "dsf", "minidsf", "mini2sf", "minigsf", "mdx",      "s98"};

    vector<string> l;
    utils::path rsnDir = utils::get_cache_dir("chipmusic") / ".rsn";
    utils::create_directory(rsnDir);
    for (auto f : utils::listRecursive(rsnDir, false))
        utils::remove(f);

    if (!utils::exists(fileName))
        return nullptr;

    try {
        auto* a = Archive::open(fileName, rsnDir, Archive::TYPE_RAR);
        a->extractAll(rsnDir);
        for (auto f : utils::listRecursive(rsnDir, false)) {
            if (song_formats.count(path_extension(f)) > 0) {
                LOGD("Found %s", f.string());
                l.push_back(f);
            }
        };
        delete a;
    } catch (archive_exception& e) {
        LOGW("Archive fail");
        return nullptr;
    }

    sort(l.begin(), l.end());

    if (l.size() > 0) {
        for (auto name : l) {
            utils::makeLower(name);
            for (auto plugin : ChipPlugin::getPlugins()) {
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

bool RSNPlugin::canHandle(const string& name)
{
    static const set<string> supported_ext{"rsn", "rps", "rdc",
                                           "rds", "rgs", "r64"};
    return supported_ext.count(utils::path_extension(name)) > 0;
}

} // namespace musix
