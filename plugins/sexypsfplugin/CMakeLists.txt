cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.sexypsfplugin)

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

add_library(sexypsfplugin ${SOURCE_FILES})
target_include_directories(sexypsfplugin PRIVATE  ../..)
target_compile_definitions(sexypsfplugin PRIVATE -DPSS_STYLE=1)

