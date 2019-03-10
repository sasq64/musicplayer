cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.gmeplugin)

file(GLOB SOURCE_FILES gme/*.cpp)

include_directories(${ZLIB_INCLUDE_DIRS})

add_library(gmeplugin GMEPlugin.cpp ${SOURCE_FILES})
target_compile_definitions(gmeplugin PRIVATE -DBLARGG_LITTLE_ENDIAN -DHAVE_ZLIB_H)
target_compile_options(gmeplugin PRIVATE -fwrapv)
target_link_libraries(gmeplugin PRIVATE coreutils ${ZLIB_LIBRARIES})
