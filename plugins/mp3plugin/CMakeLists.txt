cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.mp3plugin)


set(SOURCE_FILES MP3Plugin.cpp)

find_library(MPG123_LIBRARY libmpg123.a mpg123 REQUIRED)
find_path(MPG123_PATH mpg123.h)

if(EXISTS ${MPG123_LIBRARY})
	include_directories(${MPG123_PATH})
else()
	message("Building libmpg123 from local source")
	add_subdirectory(mpg123-1.21.0/src/libmpg123 libmpg123)
	include_directories(mpg123-1.21.0/src/libmpg123)
	set(MPG123_LIBRARY libmpg123)
endif()

message("MP3 " ${MPG123_LIBRARY})

if(NOT TARGET crypto)
	add_subdirectory(../../../crypto crypto)
endif()

find_library(CURL_LIBRARY curl REQUIRED)
find_path(CURL_INCLUDE curl/curl.h)
include_directories(${CURL_INCLUDE})

add_library(mp3plugin ${SOURCE_FILES})
target_link_libraries(mp3plugin ${MPG123_LIBRARY} ${CURL_LIBRARY})
