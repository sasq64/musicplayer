cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.gsfplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
set(SOURCE_FILES
	GSFPlugin.cpp
	playgsf/gsf.cpp
	playgsf/VBA/GBA.cpp
	playgsf/VBA/Globals.cpp
	playgsf/VBA/Sound.cpp
	playgsf/VBA/Util.cpp
	playgsf/VBA/bios.cpp
	playgsf/VBA/memgzio.c
	playgsf/VBA/snd_interp.cpp
	playgsf/VBA/unzip.cpp
	playgsf/VBA/psftag
	playgsf/libresample-0.1.3/src/resample.c
	playgsf/libresample-0.1.3/src/resamplesubs.c
	playgsf/libresample-0.1.3/src/filterkit.c
)

if(APPLE)
	set_source_files_properties(playgsf/VBA/GBA.cpp COMPILE_FLAGS -O0)
endif()

add_definitions(-DLINUX -DC_CORE)
include_directories(playgsf playgsf/libresample-0.1.3/include ..)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-parentheses-equality -Wno-dangling-else")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-parentheses-equality -Wno-dangling-else")


find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})
add_library(gsfplugin ${SOURCE_FILES})
target_link_libraries(gsfplugin ${ZLIB_LIBRARIES})
