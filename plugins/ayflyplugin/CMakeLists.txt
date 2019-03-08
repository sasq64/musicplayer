cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.ayflyplugin)


set(SOURCE_FILES
	ayfly/src/libayfly/AbstractAudio.cpp
	ayfly/src/libayfly/ay.cpp 
	ayfly/src/libayfly/formats.cpp 
	ayfly/src/libayfly/speccy.cpp 
	ayfly/src/libayfly/lha.cpp 
	ayfly/src/libayfly/common.cpp 
	ayfly/src/libayfly/ayflyString.cpp 
	ayfly/src/libayfly/Filter3.cpp
	ayfly/src/libayfly/z80ex/z80ex.c
)

include_directories(ayfly/src/libayfly ayfly/src/libayfly/z80ex/include)
add_definitions(-DDISABLE_AUDIO)
##find_package(ZLIB REQUIRED)
#include_directories(${ZLIB_INCLUDE_DIRS})

add_library(ayflyplugin AyflyPlugin.cpp ${SOURCE_FILES})
target_link_libraries(ayflyplugin PRIVATE coreutils ${ZLIB_LIBRARIES})
