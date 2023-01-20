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
if(APPLE)
  include_directories(SYSTEM /usr/local/include /opt/homebrew/include)

  link_directories(/usr/local/lib /opt/homebrew/lib)
endif()


find_package(Threads)

add_subdirectory(external/zlib)
set(ZLIB_LIBRARIES zlibstatic)
set(ZLIB_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/external/zlib ${CMAKE_BINARY_DIR}/external/zlib)
add_library(_zlib INTERFACE)
target_link_libraries(_zlib INTERFACE ${ZLIB_LIBRARIES})
target_include_directories(_zlib INTERFACE ${ZLIB_INCLUDE_DIRS})
add_library(ZLIB::ZLIB ALIAS _zlib)

if (NOT PYTHON_MODULE)

add_subdirectory(external/fmt)
add_subdirectory(external/readerwriterqueue)
add_subdirectory(external/ansi)
add_subdirectory(external/lua)
add_subdirectory(external/sol3)

add_subdirectory(${APONE}/audioplayer audioplayer)

endif()

add_subdirectory(${APONE}/coreutils coreutils)
add_subdirectory(${APONE}/crypto crypto)
add_subdirectory(${APONE}/archive archive)


add_subdirectory(src/psf)
add_subdirectory(src/stil)

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
add_subdirectory(src/plugins)


add_subdirectory(external/pybind11)

pybind11_add_module(_musix src/python.cpp)
target_link_libraries(_musix PUBLIC ${MUSICPLAYER_PLUGINS}
    coreutils crypto archive Threads::Threads)
install(TARGETS _musix DESTINATION .)
install(DIRECTORY data DESTINATION .)

if(NOT PYTHON_MODULE)

add_library(musix SHARED src/lib.cpp)
target_link_libraries(musix PUBLIC ${MUSICPLAYER_PLUGINS}
    coreutils crypto archive Threads::Threads fmt::fmt)

add_executable(play src/simple.cpp src/resampler.cpp)
target_link_libraries(play PUBLIC ${MUSICPLAYER_PLUGINS}
    apone::coreutils audioplayer apone::crypto archive Threads::Threads)

add_executable(msxp src/main.cpp src/resampler.cpp src/player.cpp src/resampler.cpp)
target_compile_definitions(msxp PUBLIC SOL_USING_CXX_LUA)
target_link_libraries(msxp PUBLIC ansi fmt::fmt lua sol2::sol2  ${MUSICPLAYER_PLUGINS}
    apone::coreutils audioplayer apone::crypto archive readerwriterqueue Threads::Threads)

install(TARGETS msxp DESTINATION /usr/local/bin)

endif()
