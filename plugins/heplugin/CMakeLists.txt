cmake_minimum_required(VERSION 3.12)
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

add_library(hiexp ${SOURCE_FILES})
target_include_directories(hiexp PRIVATE he ${ZLIB_INCLUDE_DIRS})
target_compile_definitions(hiexp PRIVATE -DEMU_COMPILE -DEMU_LITTLE_ENDIAN)
target_link_libraries(hiexp PRIVATE psf coreutils ${ZLIB_LIBRARIES})

add_library(heplugin OBJECT heplugin_register.cpp)
target_link_libraries(heplugin PRIVATE hiexp)
