cmake_minimum_required(VERSION 3.12)
project(musicplayer)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

set(APONE apone)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(external/zlib)
set(ZLIB_LIBRARIES zlibstatic)
set(ZLIB_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/external/zlib ${CMAKE_BINARY_DIR}/external/zlib)

add_subdirectory(psf)

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
    viceplugin
    # MSVC incompatible
    # mp3plugin
    # Obsolete
    # sidplugin
    # sexypsfplugin
    # modplugin
)

if(WIN32)
else()
set(THREAD_LIB pthread)
endif()

add_subdirectory(plugins)

add_subdirectory(${APONE}/coreutils coreutils)
add_subdirectory(${APONE}/crypto crypto)
add_subdirectory(${APONE}/audioplayer audioplayer)
add_subdirectory(${APONE}/archive archive)

add_executable(play main.cpp)
target_link_libraries(play PUBLIC plugin_register ${MUSICPLAYER_PLUGINS}
    coreutils audioplayer crypto archive ${THREAD_LIB})

add_library(musix STATIC lib.cpp)
target_link_libraries(musix PUBLIC plugin_register ${MUSICPLAYER_PLUGINS}
    coreutils crypto archive ${THREAD_LIB})

if(NOT WIN32)
add_executable(testing testmain.cpp test.cpp)
target_link_libraries(testing plugin_register ${MUSICPLAYER_PLUGINS} coreutils crypto archive)
endif()

install(TARGETS musix DESTINATION .)
