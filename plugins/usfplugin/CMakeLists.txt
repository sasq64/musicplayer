cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.usfplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -ffast-math -finline-functions -funswitch-loops")

set(SOURCE_FILES
	resampler.c
	USFPlugin.cpp
	lazyusf/psflib.c
	lazyusf/audio.c
	lazyusf/cpu.c
	lazyusf/dma.c
	lazyusf/exception.c
	lazyusf/interpreter_cpu.c
	lazyusf/interpreter_ops.c
	lazyusf/main.c
	lazyusf/memory.c
	lazyusf/pif.c
	lazyusf/registers.c
	lazyusf/tlb.c
	lazyusf/usf.c
	lazyusf/rsp/rsp.c
	lazyusf/rsp_hle/alist.c
	lazyusf/rsp_hle/alist_audio.c
	lazyusf/rsp_hle/alist_naudio.c
	lazyusf/rsp_hle/alist_nead.c
	lazyusf/rsp_hle/audio.c
	lazyusf/rsp_hle/cicx105.c
	lazyusf/rsp_hle/jpeg.c
	lazyusf/rsp_hle/hle.c
	lazyusf/rsp_hle/memory.c
	lazyusf/rsp_hle/mp3.c
	lazyusf/rsp_hle/musyx.c
	lazyusf/rsp_hle/plugin.c
)

#usfplugin_CFLAGS = -O3 -ffast-math -finline-functions -funswitch-loops
## -ftree-vectorizer-verbose=1 -fpredictive-commoning -fgcse-after-reload -ftree-vectorize -fipa-cp-clone
##-DARCH_MIN_ARM_NEON -mfpu=neon 
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-typedef-redefinition")

find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})

include_directories(. lazyusf lazyusf/rsp_hle)

add_library(usfplugin ${SOURCE_FILES})
target_link_libraries(usfplugin ${ZLIB_LIBRARIES})
