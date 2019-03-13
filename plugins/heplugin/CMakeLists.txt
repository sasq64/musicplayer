cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.heplugin)

set(SOURCE_FILES
    HEPlugin.cpp
    he/psx.c
    he/ioptimer.c
    he/iop.c
    he/bios.c
    he/r3000dis.c
    he/r3000asm.c
    he/r3000.c
    he/vfs.c
    he/spucore.c
    he/spu.c
    he/mkhebios.c
    he/psf2fs.c
)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-pointer-sign -Wno-implicit-function-declaration -Wno-incompatible-pointer-types")
endif()

#find_package(ZLIB REQUIRED)

add_library(heplugin ${SOURCE_FILES})
target_include_directories(heplugin PRIVATE he ${ZLIB_INCLUDE_DIRS})
target_compile_definitions(heplugin PRIVATE -DEMU_COMPILE -DEMU_LITTLE_ENDIAN)
target_link_libraries(heplugin PRIVATE psf coreutils ${ZLIB_LIBRARIES})
