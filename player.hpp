#include <filesystem>
#include <memory>
#include <optional>

struct MusicPlayer
{
    virtual ~MusicPlayer() = default;
    static std::unique_ptr<MusicPlayer> create();
    struct Info
    {
        std::optional<std::string> title;
        std::optional<std::string> composer;
    };
    virtual void run() {}
    virtual void play(std::filesystem::path const& fileName) {}
    virtual void next() {}
    virtual void prev() {}

    virtual std::optional<Info> get_info() { return std::nullopt; }
};

