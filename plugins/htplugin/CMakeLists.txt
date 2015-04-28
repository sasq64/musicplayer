cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.htplugin)


set(SOURCE_FILES
	HTPlugin.cpp
	ht/arm.c
	ht/dcsound.c
	ht/psflib.c
	ht/satsound.c
	ht/sega.c
	ht/yam.c
	ht/m68k/m68kops.c
	ht/m68k/m68kcpu.c
)

#htplugin_CFLAGS += -mfpu=neon-ftree-vectorizer-verbose=1 -fpredictive-commoning -fgcse-after-reload -ftree-vectorize -fipa-cp-clone
#-O3 -ffast-math -finline-functions -funswitch-loops

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-pointer-sign -Wno-incompatible-pointer-types")

include_directories(.)
add_definitions(-DEMU_COMPILE -DEMU_LITTLE_ENDIAN -DUSE_M68K -DHAVE_STDINT_H -DLSB_FIRST -DHAVE_MPROTECT)

find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})

add_library(htplugin ${SOURCE_FILES})
target_link_libraries(htplugin ${ZLIB_LIBRARIES})
