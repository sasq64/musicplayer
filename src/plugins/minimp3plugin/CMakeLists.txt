cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.minimp3plugin)

add_library(minimp3plugin MP3Plugin.cpp)

# TODO we use libmp3 in the main app too, so public. Bad.
target_include_directories(minimp3plugin PUBLIC minimp3)
target_compile_definitions(minimp3plugin PRIVATE MINIMP3_IMPLEMENTATION)
target_link_libraries(minimp3plugin PUBLIC coreutils)

