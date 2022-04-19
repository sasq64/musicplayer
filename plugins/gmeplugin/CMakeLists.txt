cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.gmeplugin)

file(GLOB SOURCE_FILES gme/*.cpp)

add_library(gmeplugin GMEPlugin.cpp ${SOURCE_FILES})
target_compile_definitions(gmeplugin PRIVATE
    BLARGG_LITTLE_ENDIAN HAVE_ZLIB_H VGM_YM2612_NUKED)
#VGM_YM2612_GENS VGM_YM2612_MAME)
target_compile_options(gmeplugin PRIVATE -fwrapv)
target_link_libraries(gmeplugin PRIVATE coreutils ${ZLIB_LIBRARIES})
target_include_directories(gmeplugin PRIVATE psf ${ZLIB_INCLUDE_DIRS})
