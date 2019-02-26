cmake_minimum_required(VERSION 3.12)
project(musicplayer)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

set(AP1_ROOT ../apone CACHE PATH "Where apone is checked out")
set(APONE ${AP1_ROOT}/mods)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(MUSICPLAYER_PLUGINS
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
    mp3plugin
    ndsplugin
    openmptplugin
    rsnplugin
    s98plugin
    sc68plugin
    stsoundplugin
    tedplugin
    uadeplugin
    usfplugin
    viceplugin
    v2plugin
    # Obsolete
    # sexypsfplugin
    # modplugin
)
add_subdirectory(plugins)

add_subdirectory(${APONE}/coreutils coreutils)
add_subdirectory(${APONE}/crypto crypto)
add_subdirectory(${APONE}/audioplayer audioplayer)
add_subdirectory(${APONE}/archive archive)

add_executable(play main.cpp)
target_link_libraries(play plugin_register ${MUSICPLAYER_PLUGINS} coreutils audioplayer crypto archive pthread)

add_library(musix SHARED lib.cpp)
target_link_libraries(musix plugin_register ${MUSICPLAYER_PLUGINS} coreutils crypto archive pthread)

