cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.v2plugin)

set(SOURCE_FILES 
    V2Plugin.cpp
    ronan.cpp
    v2mplayer.cpp
    v2mconv.cpp
    synth_core.cpp
    sounddef.cpp
)

add_library(v2plugin ${SOURCE_FILES})
target_link_libraries(v2plugin PRIVATE coreutils)
target_compile_definitions(v2plugin PRIVATE -DRONAN)
