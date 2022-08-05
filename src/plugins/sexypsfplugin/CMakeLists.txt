cmake_minimum_required(VERSION 3.12)
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

add_library(sexypsf ${SOURCE_FILES})
target_include_directories(sexypsf PRIVATE  ../..)
target_compile_definitions(sexypsf PRIVATE -DPSS_STYLE=1)
