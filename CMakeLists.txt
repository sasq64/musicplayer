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
  include_directories(external/win)
endif()

find_package(Threads)

add_subdirectory(external/zlib)
set(ZLIB_LIBRARIES zlibstatic)
set(ZLIB_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/external/zlib ${CMAKE_BINARY_DIR}/external/zlib)
add_library(_zlib INTERFACE)
target_link_libraries(_zlib INTERFACE ${ZLIB_LIBRARIES})
target_include_directories(_zlib INTERFACE ${ZLIB_INCLUDE_DIRS})
add_library(ZLIB::ZLIB ALIAS _zlib)

add_subdirectory(external/fmt)
add_subdirectory(external/readerwriterqueue)
add_subdirectory(external/ansi)

add_subdirectory(${APONE}/coreutils coreutils)
add_subdirectory(${APONE}/crypto crypto)
add_subdirectory(${APONE}/audioplayer audioplayer)
add_subdirectory(${APONE}/archive archive)


add_subdirectory(psf)
add_subdirectory(stil)

set(MUSICPLAYER_PLUGINS
    adplugin
    aoplugin
    ayflyplugin
    # ffmpegplugin
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
    sidplugin
    # MSVC incompatible
    # mp3plugin
    # Obsolete
    # tfmxplugin
    # sexypsfplugin
    # modplugin
)

add_subdirectory(plugins)

add_library(musix SHARED lib.cpp)
target_link_libraries(musix PUBLIC ${MUSICPLAYER_PLUGINS}
    coreutils crypto archive Threads::Threads)

add_executable(play simple.cpp resampler.cpp)
target_link_libraries(play PUBLIC ${MUSICPLAYER_PLUGINS}
    apone::coreutils audioplayer apone::crypto archive Threads::Threads)

add_executable(msxp main.cpp resampler.cpp player.cpp resampler.cpp)
target_link_libraries(msxp PUBLIC ansi fmt::fmt ${MUSICPLAYER_PLUGINS}
    apone::coreutils audioplayer apone::crypto archive readerwriterqueue Threads::Threads)

install(TARGETS msxp DESTINATION /usr/local/bin)

if(APPLE)
  include_directories(SYSTEM /usr/local/include /opt/homebrew/include)
  link_directories(/usr/local/lib /opt/homebrew/lib)
endif()
