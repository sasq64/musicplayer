cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.aoplugin)

set(SOURCE_FILES
    aosdk/eng_qsf/eng_qsf.c
    aosdk/eng_qsf/kabuki.c
    aosdk/eng_qsf/qsound.c
    aosdk/eng_qsf/z80.c
    
    aosdk/eng_psf/eng_psf2.c
    aosdk/eng_psf/peops2/spu.c
    aosdk/eng_psf/peops2/dma.c
    aosdk/eng_psf/peops2/registers.c

    aosdk/eng_psf/eng_psf.c
    aosdk/eng_psf/eng_spu.c
    aosdk/eng_psf/psx.c
    aosdk/eng_psf/psx_hw.c
    aosdk/eng_psf/peops/spu.c

    aosdk/eng_ssf/m68kcpu.c
    aosdk/eng_ssf/m68kopac.c
    aosdk/eng_ssf/m68kopdm.c
    aosdk/eng_ssf/m68kopnz.c
    aosdk/eng_ssf/m68kops.c
    aosdk/eng_ssf/scsp.c
    aosdk/eng_ssf/scspdsp.c
    aosdk/eng_ssf/sat_hw.c
    aosdk/eng_ssf/eng_ssf.c

    aosdk/corlett.c
)

add_library(aosdk AOPlugin.cpp ${SOURCE_FILES})
target_include_directories(aosdk PRIVATE aosdk/eng_ssf aosdk ${ZLIB_INCLUDE_DIRS})
target_link_libraries(aosdk PRIVATE coreutils ${ZLIB_LIBRARIES})
if(NOT WIN32)
    target_compile_options(aosdk PRIVATE -Wno-implicit-function-declaration)
endif()

add_library(aoplugin OBJECT aoplugin_register.cpp)
target_link_libraries(aoplugin PRIVATE aosdk)