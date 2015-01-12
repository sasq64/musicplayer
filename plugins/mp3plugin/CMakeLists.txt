cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.mp3plugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
set(SOURCE_FILES MP3Plugin.cpp)

#find_library(MPG123_LIBRARY mpg123)
#find_path(MPG123_PATH mpg123.h)
#include_directories(${MPG123_PATH})

#message(${MPG123_LIBRARY})

add_subdirectory(mpg123-1.21.0/src/libmpg123 libmpg123)
include_directories(mpg123-1.21.0/src/libmpg123)

if (NOT TARGET crypto)
	if (${CPP_MODS})
		add_subdirectory(${CPP_MODS}/crypto crypto)
	else()
		add_subdirectory(../../../crypto crypto)
	endif()
endif()


add_library(mp3plugin ${SOURCE_FILES})
target_link_libraries(mp3plugin libmpg123 curl)
#${MPG123_LIBRARY})
