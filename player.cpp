#include "chipplayer.h"
#include "chipplugin.h"

#include <audioplayer/audioplayer.h>
#include <coreutils/log.h>
#include <coreutils/utils.h>

#include "resampler.h"

#include <imgui.h>

#include <ImGuiFileBrowser.h>
#include <backends/imgui_impl_glfw.h>
#include <backends/imgui_impl_opengl3.h>

#include <cstdio>

#if defined(IMGUI_IMPL_OPENGL_ES2)
#    include <GLES2/gl2.h>
#endif
#include <GLFW/glfw3.h> // Will drag system OpenGL headers

class MusicPlayer
{
    std::shared_ptr<musix::ChipPlayer> player;
    std::string pluginName;

    Resampler<32768> fifo{44100};
    AudioPlayer audioPlayer{44100};
public:
    std::shared_ptr<musix::ChipPlayer> get_player() {
        return player;
    }

    MusicPlayer()
    {
        using musix::ChipPlayer;
        using musix::ChipPlugin;

        logging::setLevel(logging::Level::Warning);

        ChipPlugin::createPlugins("data");

        audioPlayer.play([&](int16_t* ptr, int size) {
            auto count = fifo.read(ptr, size);
            if (count <= 0) { memset(ptr, 0, size * 2); }
        });
    }

    int play(std::string const& name)
    {
        player = nullptr;
        for (const auto& plugin : musix::ChipPlugin::getPlugins()) {
            if (plugin->canHandle(name)) {
                if (auto* ptr = plugin->fromFile(name)) {
                    player = std::shared_ptr<musix::ChipPlayer>(ptr);
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
        if (title.empty()) { title = utils::path_basename(name); }

        auto format = player->getMeta("format");
        printf("Playing: %s [%s/%s] (%02d:%02d)\n", title.c_str(),
               pluginName.c_str(), format.c_str(), len / 60, len % 60);
        return 1;
    }

    int song = 0;

    void next()
    {
        song++;
        player->seekTo(song);
    }

    void update()
    {
        if (player == nullptr) { return; }
        if (fifo.filled() > 8192) return;
        std::array<int16_t, 1024 * 16> temp{};
        fifo.setHz(player->getHZ());
        auto rc =
            player->getSamples(temp.data(), static_cast<int>(temp.size()));
        if (rc > 0) { fifo.write(&temp[0], &temp[1], rc); }
    }
};

void text(std::string_view t)
{
    ImGui::TextUnformatted(t.begin(), t.end());
}

imgui_addons::ImGuiFileBrowser file_dialog;
int main()
{
    glfwInit();

    const char* glsl_version = "#version 150";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); // 3.2+ only
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // Required on Mac

    GLFWwindow* window = glfwCreateWindow(
        1280, 720, "Dear ImGui GLFW+OpenGL3 example", NULL, NULL);
    if (window == NULL) return 1;
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1); // Enable vsync

    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    (void)io;
    // io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable
    // Keyboard Controls io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad; //
    // Enable Gamepad Controls

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();
    // ImGui::StyleColorsClassic();
    // Setup Platform/Renderer backends
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init(glsl_version);
    ImVec4 clear_color = ImVec4(0.45F, 0.55F, 0.60F, 1.00F);

    MusicPlayer player;
    while (glfwWindowShouldClose(window) == 0) {
        glfwPollEvents();

        // Start the Dear ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        ImGui::SetNextWindowPos(ImVec2(0, 0));
        ImGui::SetNextWindowSize(ImVec2(640, 480));
        ImGui::Begin("x", nullptr,
                     ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize);
        bool open = false;
        auto p = player.get_player();

        if (p != nullptr) {
            text(fmt::format("Title: {}", p->getMeta("title")));
            text(fmt::format("Composer: {}", p->getMeta("composer")));
            text(fmt::format("Format: {}", p->getMeta("format")));
            text(fmt::format("Length: {}", p->getMetaInt("length")));
        }

        if (ImGui::Button("Open")) {
            printf("Open\n");
            open = true;
        }
        if (ImGui::Button("Next")) {
            player.next();
        }
        ImGui::Text("This is some useful text.");
        // Remember the name to ImGui::OpenPopup() and showFileDialog() must be
        // same...
        if (open) { ImGui::OpenPopup("Open File"); }
        if (file_dialog.showFileDialog(
                "Open File", imgui_addons::ImGuiFileBrowser::DialogMode::OPEN,
                ImVec2(700, 310), "*.*")) {
            printf("Close\n");
            std::string p = file_dialog.selected_path;//+ "/" + file_dialog.selected_fn;
            player.play(p);
        }
        open = false;

        ImGui::End();

        ImGui::Render();
        int display_w = 640;
        int display_h = 480;
        //        glfwGetFramebufferSize(window, &display_w, &display_h);
        glViewport(0, 0, display_w, display_h);
        glClearColor(clear_color.x, clear_color.y, clear_color.z,
                     clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        glfwSwapBuffers(window);

        player.update();
    }

    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();
}