cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.gmeplugin)



file(GLOB SOURCE_FILES gme/*.cpp)
add_definitions(-DBLARGG_LITTLE_ENDIAN -DHAVE_ZLIB_H)

find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})

add_library(gmeplugin GMEPlugin.cpp ${SOURCE_FILES})
target_link_libraries(gmeplugin ${ZLIB_LIBRARIES})
