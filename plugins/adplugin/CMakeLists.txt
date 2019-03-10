cmake_minimum_required(VERSION 3.4)
project(cpp-mods.musicplayer.adplugin)

set(SOURCE_FILES
        AdPlugin.cpp
        opl/dbopl.cpp
        libbinio/binfile.cpp
        libbinio/binio.cpp
        libbinio/binstr.cpp
        libbinio/binwrap.cpp
        adplug/a2m.cpp
        adplug/adl.cpp
        adplug/adlibemu.c
        adplug/adplug.cpp
        adplug/adtrack.cpp
        adplug/amd.cpp
        adplug/bam.cpp
        adplug/bmf.cpp
        adplug/cff.cpp
        adplug/cmf.cpp
        adplug/d00.cpp
        adplug/database.cpp
        adplug/debug.c
        adplug/dfm.cpp
        adplug/diskopl.cpp
        adplug/dmo.cpp
        adplug/dro.cpp
        adplug/dro2.cpp
        adplug/dtm.cpp
        adplug/emuopl.cpp
        adplug/flash.cpp
        adplug/fmc.cpp
        adplug/fmopl.c
        adplug/fprovide.cpp
        adplug/hsc.cpp
        adplug/hsp.cpp
        adplug/hybrid.cpp
        adplug/hyp.cpp
        adplug/imf.cpp
        adplug/jbm.cpp
        adplug/ksm.cpp
        adplug/lds.cpp
        adplug/mad.cpp
        adplug/mid.cpp
        adplug/mkj.cpp
        adplug/msc.cpp
        adplug/mtk.cpp
        adplug/player.cpp
        adplug/players.cpp
        adplug/protrack.cpp
        adplug/psi.cpp
        adplug/rad.cpp
        adplug/rat.cpp
        adplug/raw.cpp
        adplug/rix.cpp
        adplug/rol.cpp
        adplug/s3m.cpp
        adplug/sa2.cpp
        adplug/sng.cpp
        adplug/surroundopl.cpp
        adplug/temuopl.cpp
        adplug/u6m.cpp
        adplug/xad.cpp
        adplug/xsm.cpp
)

add_library(adplugin ${SOURCE_FILES})
target_include_directories(adplugin PRIVATE opl libbinio adplug)
target_link_libraries(adplugin PRIVATE coreutils)

