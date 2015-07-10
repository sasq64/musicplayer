cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.usfplugin)


#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -ffast-math -finline-functions -funswitch-loops")
if(0)
set(SOURCE_FILES
	lazyusf/psflib.c
	lazyusf/audio.c
	lazyusf/cpu.c
	lazyusf/dma.c
	lazyusf/exception.c
	lazyusf/interpreter_cpu.c
	lazyusf/interpreter_ops.c
	lazyusf/main.c
	lazyusf/pif.c
	lazyusf/registers.c
	lazyusf/tlb.c
	lazyusf/usf.c
	lazyusf/memory.c
	lazyusf/cpu_hle.c
	lazyusf/audiolib.c
	lazyusf/os.c
	lazyusf/rsp/rsp.c
	lazyusf/rsp_hle/alist.c
	lazyusf/rsp_hle/alist_nead.c
	lazyusf/rsp_hle/jpeg.c
	lazyusf/rsp_hle/mp3.c
	lazyusf/rsp_hle/alist_audio.c
	lazyusf/rsp_hle/audio.c
	lazyusf/rsp_hle/hle.c
	lazyusf/rsp_hle/musyx.c
	lazyusf/rsp_hle/alist_naudio.c
	lazyusf/rsp_hle/cicx105.c
	lazyusf/rsp_hle/memory.c
	lazyusf/rsp_hle/plugin.c
)
else()
set(SOURCE_FILES
	lazyusf2/r4300/empty_dynarec.c
	lazyusf2/psflib.c
	lazyusf2/ai/ai_controller.c
	lazyusf2/api/callbacks.c
	lazyusf2/debugger/dbg_decoder.c
	lazyusf2/main/main.c
	lazyusf2/main/rom.c
	lazyusf2/main/savestates.c
	lazyusf2/main/util.c
	lazyusf2/memory/memory.c
	lazyusf2/pi/cart_rom.c
	lazyusf2/pi/pi_controller.c
	lazyusf2/r4300/cached_interp.c
	lazyusf2/r4300/cp0.c
	lazyusf2/r4300/cp1.c
	lazyusf2/r4300/exception.c
	lazyusf2/r4300/instr_counters.c
	lazyusf2/r4300/interupt.c
	lazyusf2/r4300/mi_controller.c
	lazyusf2/r4300/pure_interp.c
	lazyusf2/r4300/r4300.c
	lazyusf2/r4300/r4300_core.c
	lazyusf2/r4300/recomp.c
	lazyusf2/r4300/reset.c
	lazyusf2/r4300/tlb.c
	lazyusf2/rdp/rdp_core.c
	lazyusf2/ri/rdram.c
	lazyusf2/ri/rdram_detection_hack.c
	lazyusf2/ri/ri_controller.c
	lazyusf2/rsp/rsp_core.c
	lazyusf2/rsp_hle/alist.c
	lazyusf2/rsp_hle/alist_audio.c
	lazyusf2/rsp_hle/alist_naudio.c
	lazyusf2/rsp_hle/alist_nead.c
	lazyusf2/rsp_hle/audio.c
	lazyusf2/rsp_hle/cicx105.c
	lazyusf2/rsp_hle/hle.c
	lazyusf2/rsp_hle/jpeg.c
	lazyusf2/rsp_hle/memory.c
	lazyusf2/rsp_hle/mp3.c
	lazyusf2/rsp_hle/musyx.c
	lazyusf2/rsp_hle/plugin.c
	lazyusf2/rsp_lle/rsp.c
	lazyusf2/si/cic.c
	lazyusf2/si/game_controller.c
	lazyusf2/si/n64_cic_nus_6105.c
	lazyusf2/si/pif.c
	lazyusf2/si/si_controller.c
	lazyusf2/usf/barray.c
	lazyusf2/usf/resampler.c
	lazyusf2/usf/usf.c
	lazyusf2/vi/vi_controller.c
)
endif()
#usfplugin_CFLAGS = -O3 -ffast-math -finline-functions -funswitch-loops
## -ftree-vectorizer-verbose=1 -fpredictive-commoning -fgcse-after-reload -ftree-vectorize -fipa-cp-clone
#if(RASPBERRY)
#	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DARCH_MIN_ARM_NEON -ftree-vectorizer-verbose=1 -fpredictive-commoning -fgcse-after-reload -ftree-vectorize -fipa-cp-clone")
#endif()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-typedef-redefinition")

find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})

include_directories(. lazyusf2 lazyusf2/rsp_hle)

add_library(usfplugin USFPlugin.cpp resampler.c ${SOURCE_FILES})
target_link_libraries(usfplugin ${ZLIB_LIBRARIES})
