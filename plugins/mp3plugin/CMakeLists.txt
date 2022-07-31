cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.mp3plugin)

set(SOURCE_FILES MP3Plugin.cpp)

find_library(MPG123_LIBRARY mpg123 REQUIRED)
find_path(MPG123_PATH mpg123.h)

add_library(mp3lib ${SOURCE_FILES})

# TODO we use libmp3 in the main app too, so public. Bad.
target_include_directories(mp3lib PUBLIC ${MPG123_PATH})
target_link_libraries(mp3lib PUBLIC coreutils ${MPG123_LIBRARY})

add_library(mp3plugin OBJECT mp3plugin_register.cpp)
target_link_libraries(mp3plugin PRIVATE mp3lib)
