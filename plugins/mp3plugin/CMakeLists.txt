cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.mp3plugin)


set(SOURCE_FILES MP3Plugin.cpp)

find_library(MPG123_LIBRARY libmpg123.lib REQUIRED)
find_path(MPG123_PATH mpg123.h)
include_directories(${MPG123_PATH})
#find_package(mpg123 REQUIRED)


if(NOT TARGET crypto)
	add_subdirectory(../../../crypto crypto)
endif()

add_library(mp3plugin ${SOURCE_FILES})
target_link_libraries(mp3plugin ${MPG123_LIBRARY})
