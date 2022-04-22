cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.htplugin)

set(SOURCE_FILES
    HTPlugin.cpp
    ht/arm.c
    ht/dcsound.c
    ht/satsound.cpp
    ht/sega.c
    ht/yam.c
    ht/m68k/m68kops.cpp
    ht/m68k/m68kcpu.cpp
)

#find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})

add_library(hitech ${SOURCE_FILES})
##target_compile_options(hitech PRIVATE -Wno-pointer-sign -Wno-incompatible-pointer-types)
target_include_directories(hitech PRIVATE .)
target_compile_definitions(hitech PRIVATE -DEMU_COMPILE -DEMU_LITTLE_ENDIAN -DUSE_M68K -DHAVE_STDINT_H -DLSB_FIRST -DHAVE_MPROTECT)
target_link_libraries(hitech PRIVATE psf coreutils ${ZLIB_LIBRARIES})

add_library(htplugin OBJECT htplugin_register.cpp)
target_link_libraries(htplugin PRIVATE hitech)