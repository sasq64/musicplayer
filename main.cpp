
#include "chipplayer.h"
#include "chipplugin.h"

#include <audioplayer/audioplayer.h>
#include <coreutils/fifo.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include <atomic>
#include <chrono>
#include <csignal>
#include <string>

template <typename T, size_t SIZE> struct Ring
{
    T data[SIZE];
    std::atomic<size_t> read_pos{0};
    std::atomic<size_t> write_pos{0};

    void write(T const* source, size_t n)
    {
        while (write_pos + n - read_pos > SIZE) {
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }
        for (size_t i = 0; i < n; i++)
            data[(write_pos + i) % SIZE] = source[i];
        write_pos += n;
    }

    size_t read(T* target, size_t n)
    {
        auto left = write_pos - read_pos;
        if (left < n)
            n = left;
        for (size_t i = 0; i < n; i++)
            target[i] = data[(read_pos + i) % SIZE];
        read_pos += n;
        return n;
    }
};

using namespace std::string_literals;

int main(int argc, const char** argv)
{
    using musix::ChipPlayer;
    using musix::ChipPlugin;

    if (argc < 2)
        return 0;

    logging::setLevel(logging::Level::Debug);

    std::string name = argv[1];
    std::string pluginName;

    ChipPlugin::createPlugins("data");

    std::shared_ptr<ChipPlayer> player;

    for (const auto& plugin : ChipPlugin::getPlugins()) {
        if (plugin->canHandle(name)) {
            if (auto ptr = plugin->fromFile(name)) {
                player = std::shared_ptr<ChipPlayer>(ptr);
                pluginName = plugin->name();
                break;
            }
        }
    }
    if (!player) {
        printf("No plugin could handle file\n");
        return 0;
    }
    auto len = player->getMetaInt("length");
    auto title = player->getMeta("title");
    if (title.empty())
        title = utils::path_basename(name);

    auto format = player->getMeta("format");
    printf("Playing: %s [%s/%s] (%02d:%02d)\n", title.c_str(),
           pluginName.c_str(), format.c_str(), len / 60, len % 60);

    Ring<int16_t, 32768> fifo;

    AudioPlayer ap{44100};
    ap.play([&](int16_t* ptr, int size) {
        int rc = fifo.read(ptr, size);
        if (rc <= 0)
            memset(ptr, 0, size * 2);
    });

    std::signal(SIGINT, [](int) { std::quick_exit(0); });

    std::vector<int16_t> temp(1024 * 16);
    while (true) {
        int rc = player->getSamples(&temp[0], temp.size());
        if (rc > 0)
            fifo.write(&temp[0], rc);
    }
    return 0;
}
