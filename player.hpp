#include <filesystem>
#include <memory>
#include <optional>
#include <variant>
#include <vector>

using Meta = std::variant<std::string, double, uint32_t>;

struct MusicPlayer
{
    virtual ~MusicPlayer() = default;
    static std::unique_ptr<MusicPlayer> create();
static std::unique_ptr<MusicPlayer> createWriter();
    virtual void update() {}
    virtual void clear() {}
    virtual void play(std::filesystem::path const& fileName) {}

    virtual void next() {}
    virtual void set_song(int song) {}

    virtual void detach() {}

    using Info = std::pair<std::string, Meta>;

    virtual std::vector<Info> get_info() { return {}; }
};

