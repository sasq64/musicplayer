cmake_minimum_required(VERSION 2.8.4)
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


add_library(aoplugin AOPlugin.cpp ${SOURCE_FILES})
target_include_directories(aoplugin PRIVATE aosdk/eng_ssf aosdk ${ZLIB_INCLUDE_DIRS})
#target_compile_options(aoplugin PRIVATE -Wno-format -Wno-implicit-function-declaration)
target_link_libraries(aoplugin PRIVATE coreutils ${ZLIB_LIBRARIES})
