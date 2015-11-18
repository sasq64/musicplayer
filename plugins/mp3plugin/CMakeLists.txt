cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.mp3plugin)


set(SOURCE_FILES MP3Plugin.cpp)

find_library(MPG123_LIBRARY mpg123 mpg123 REQUIRED)
find_path(MPG123_PATH mpg123.h)

include_directories(${MPG123_PATH})

message("MP3 " ${MPG123_LIBRARY})

if(NOT TARGET crypto)
	add_subdirectory(../../../crypto crypto)
endif()

add_library(mp3plugin ${SOURCE_FILES})
target_link_libraries(mp3plugin ${MPG123_LIBRARY})
