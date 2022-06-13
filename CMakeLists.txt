cmake_minimum_required(VERSION 3.12)
project(musicplayer)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
include(FetchContent)
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

set(APONE apone)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (WIN32)
  # HACK to make an empty unistd.h available only to Windows
  include_directories(externa￣l/win)
endif()
add_subdirectory(external/zlib)
set(ZLIB_LIBRARIES zlibstatic)
set(ZLIB_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/external/zlib ${CMAKE_BINARY_DIR}/external/zlib)
add_library(_zlib INTERFACE)
target_link_libraries(_zlib INTERFACE ${ZLIB_LIBRARIES})
target_include_directories(_zlib INTERFACE ${ZLIB_INCLUDE_DIRS})
add_library(ZLIB::ZLIB ALIAS _zlib)

add_subdirectory(external/fmt)
option(ELEMENTS_BUILD_EXAMPLES "" OFF)
add_subdirectory(external/elements)
add_subdirectory(external/readerwriterqueue)
add_subdirectory(external/portable-file-dialogs)

add_subdirectory(${APONE}/coreutils coreutils)
add_subdirectory(${APONE}/crypto crypto)
add_subdirectory(${APONE}/audioplayer audioplayer)
add_subdirectory(${APONE}/archive archive)


add_subdirectory(psf)
add_subdirectory(stil)

set(MUSICPLAYER_PLUGINS
    tfmxplugin
    adplugin
    aoplugin
    ayflyplugin
    ffmpegplugin
    gmeplugin
    gsfplugin
    heplugin
    hivelyplugin
    htplugin
    mdxplugin
    ndsplugin
    openmptplugin
    sc68plugin
    stsoundplugin
    tedplugin
    uadeplugin
    v2plugin
    usfplugin
    rsnplugin
    s98plugin
    # viceplugin
    # mp3plugin
    # MSVC incompatible
    # Obsolete
    sidplugin
    # sexypsfplugin
    # modplugin
)

if(WIN32)
else()
set(THREAD_LIB pthread)
endif()

add_subdirectory(plugins)


add_executable(play main.cpp resampler.cpp)
target_link_libraries(play PUBLIC fmt::fmt ${MUSICPLAYER_PLUGINS}
    apone::coreutils audioplayer apone::crypto archive ${THREAD_LIB})

add_library(musix SHARED lib.cpp)
target_link_libraries(musix PUBLIC ${MUSICPLAYER_PLUGINS}
    coreutils crypto archive ${THREAD_LIB})

if(APPLE)
  include_directories(SYSTEM /usr/local/include /opt/homebrew/include)
  link_directories(/usr/local/lib /opt/homebrew/lib)
endif()

# find_package(OpenGL)
# find_package(GLEW REQUIRED)
# find_package(SDL2 REQUIRED)
# message(INFO ${SDL2_INCLUDE_DIRS})

# add_library(imgui STATIC
#     imgui/imgui.cpp imgui/imgui_draw.cpp imgui/imgui_tables.cpp
#     imgui/imgui_widgets.cpp
#     imgui/backends/imgui_impl_glfw.cpp
#     imgui/backends/imgui_impl_opengl3.cpp
#     ImGui-Addons/FileBrowser/ImGuiFileBrowser.cpp
#     )
# target_link_libraries(imgui PUBLIC OpenGL::GL GLEW::GLEW SDL2 glfw)
# target_include_directories(imgui PUBLIC imgui ImGui-Addons/FileBrowser)

add_executable(player ui.cpp player.cpp resampler.cpp)
target_link_libraries(player PRIVATE cycfi::elements
    portable_file_dialogs
fmt::fmt ${MUSICPLAYER_PLUGINS} readerwriterqueue
    apone::coreutils audioplayer apone::crypto archive ${THREAD_LIB})
target_link_libraries(player PRIVATE "-framework Cocoa" "-framework IOKit")

if(NOT WIN32)
add_executable(musixtest testmain.cpp test.cpp)
target_link_libraries(musixtest fmt::fmt ${MUSICPLAYER_PLUGINS}
    coreutils crypto archive)
endif()

install(TARGETS musix DESTINATION .)
