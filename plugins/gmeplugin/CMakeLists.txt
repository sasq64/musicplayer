cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.gmeplugin)

file(GLOB SOURCE_FILES gme/*.cpp)

add_library(gme GMEPlugin.cpp ${SOURCE_FILES})
target_compile_definitions(gme PRIVATE
    BLARGG_LITTLE_ENDIAN HAVE_ZLIB_H VGM_YM2612_NUKED)
#VGM_YM2612_GENS VGM_YM2612_MAME)
target_compile_options(gme PRIVATE -fwrapv)
target_link_libraries(gme PRIVATE coreutils ${ZLIB_LIBRARIES})
target_include_directories(gme PRIVATE psf ${ZLIB_INCLUDE_DIRS})

add_library(gmeplugin OBJECT gmeplugin_register.cpp)
target_link_libraries(gmeplugin PRIVATE gme)
