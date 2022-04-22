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

add_library(v2m ${SOURCE_FILES})
target_link_libraries(v2m PRIVATE coreutils)
target_compile_definitions(v2m PRIVATE -DRONAN)
target_compile_options(v2m PRIVATE -fwrapv)

add_library(v2plugin OBJECT v2plugin_register.cpp)
target_link_libraries(v2plugin PRIVATE v2m)
