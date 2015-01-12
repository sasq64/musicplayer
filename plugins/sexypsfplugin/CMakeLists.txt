cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.sexypsfplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
set(SOURCE_FILES
	SexyPSFPlugin.cpp
	sexypsf/Misc.c
	sexypsf/PsxBios.c
	sexypsf/PsxCounters.c
	sexypsf/PsxDma.c
	sexypsf/PsxHLE.c
	sexypsf/PsxHw.c
	sexypsf/PsxInterpreter.c
	sexypsf/PsxMem.c
	sexypsf/R3000A.c
	sexypsf/Spu.c
	sexypsf/spu/spu.c
)
include_directories(../..)

add_definitions(-DPSS_STYLE=1)

add_library(sexypsfplugin ${SOURCE_FILES})
