cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.usfplugin)

set(SOURCE_FILES
    lazyusf2/r4300/empty_dynarec.c
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
    #lazyusf2/r4300/instr_counters.c
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
    #lazyusf2/usf/resampler.c
    lazyusf2/usf/usf.c
    lazyusf2/vi/vi_controller.c
)

#find_package(ZLIB REQUIRED)

add_library(usfplugin USFPlugin.cpp resampler.c ${SOURCE_FILES})
target_link_libraries(usfplugin PRIVATE psf coreutils ${ZLIB_LIBRARIES})

if(MSVC)
target_compile_options(usfplugin PRIVATE -DNO_ASM)
endif()

target_include_directories(usfplugin PRIVATE ${ZLIB_INCLUDE_DIRS} . lazyusf2 lazyusf2/rsp_hle)
