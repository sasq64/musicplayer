cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.mp3plugin)

set(SOURCE_FILES MP3Plugin.cpp)

find_library(MPG123_LIBRARY mpg123 REQUIRED)
find_path(MPG123_PATH mpg123.h)

add_library(mp3plugin ${SOURCE_FILES})

# TODO we use libmp3 in the main app too, so public. Bad.
target_include_directories(mp3plugin PUBLIC ${MPG123_PATH})
target_link_libraries(mp3plugin PUBLIC coreutils ${MPG123_LIBRARY})
