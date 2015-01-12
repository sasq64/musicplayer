cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.heplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
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
	he/psflib.c
)

add_definitions(-DEMU_COMPILE -DEMU_LITTLE_ENDIAN)

#htplugin_LDFLAGS := -Wl,--fix-cortex-a8
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-pointer-sign -Wno-implicit-function-declaration -Wno-incompatible-pointer-types")

include_directories(he)



add_library(heplugin ${SOURCE_FILES})
