#include <filesystem>
#include <memory>
#include <optional>
#include <variant>
#include <vector>

struct MusicPlayer
{
    virtual ~MusicPlayer() = default;
    static std::unique_ptr<MusicPlayer> create();
    //virtual void run() {}
    virtual void update() {}
    virtual void play(std::filesystem::path const& fileName) {}
    virtual void next() {}
    virtual void prev() {}

    using Info = std::pair<std::string, std::variant<std::string, double, uint32_t>>;

    virtual std::vector<Info> get_info() { return {}; }
};

