cmake_minimum_required(VERSION 3.5)
project(cpp-mods.musicplayer.sidplugin)

set(SOURCE_FILES
    SidPlugin.cpp
    libsidplayfp/src/psiddrv.cpp
    libsidplayfp/src/reloc65.cpp
    libsidplayfp/src/c64/VIC_II/mos656x.cpp
    libsidplayfp/src/c64/CPU/mos6510.cpp
    #libsidplayfp/src/c64/CPU/mos6510debug.cpp
    libsidplayfp/src/c64/c64.cpp
    libsidplayfp/src/c64/mmu.cpp
    libsidplayfp/src/c64/CIA/tod.cpp
    libsidplayfp/src/c64/CIA/timer.cpp
    libsidplayfp/src/c64/CIA/mos6526.cpp
    libsidplayfp/src/player.cpp
    libsidplayfp/src/builders/residfp-builder/residfp-emu.cpp
    libsidplayfp/src/builders/residfp-builder/residfp-builder.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/OpAmp.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/resample/SincResampler.cpp
    #libsidplayfp/src/builders/residfp-builder/residfp/resample/test.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/EnvelopeGenerator.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/Dac.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/WaveformGenerator.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/SID.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/FilterModelConfig.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/Filter.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/Filter6581.cpp
    #libsidplayfp/src/builders/residfp-builder/residfp/Integrator.cpp
    #libsidplayfp/src/builders/residfp-builder/residfp/Integrator8580.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/ExternalFilter.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/FilterModelConfig8580.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/Filter8580.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/WaveformCalculator.cpp
    libsidplayfp/src/builders/residfp-builder/residfp/Spline.cpp
    libsidplayfp/src/sidtune/PSID.cpp
    libsidplayfp/src/sidtune/SidTuneBase.cpp
    libsidplayfp/src/sidtune/MUS.cpp
    libsidplayfp/src/sidtune/SidTuneTools.cpp
    libsidplayfp/src/sidtune/prg.cpp
    libsidplayfp/src/sidtune/p00.cpp
    libsidplayfp/src/sidemu.cpp
    libsidplayfp/src/mixer.cpp
    libsidplayfp/src/utils/md5Factory.cpp
    libsidplayfp/src/utils/MD5/MD5.cpp
    libsidplayfp/src/utils/iniParser.cpp
    #libsidplayfp/src/utils/STILview/stil.cpp
    #libsidplayfp/src/utils/SidDatabase.cpp
    libsidplayfp/src/EventScheduler.cpp
    libsidplayfp/src/sidplayfp/SidConfig.cpp
    libsidplayfp/src/sidplayfp/sidplayfp.cpp
    libsidplayfp/src/sidplayfp/SidInfo.cpp
    libsidplayfp/src/sidplayfp/sidbuilder.cpp
    libsidplayfp/src/sidplayfp/SidTune.cpp
    libsidplayfp/src/sidplayfp/SidTuneInfo.cpp
)

add_library(sidplugin ${SOURCE_FILES})
target_link_libraries(sidplugin PRIVATE coreutils)
target_compile_options(sidplugin PRIVATE -DHAVE_CXX11 -DPACKAGE_NAME="" -DPACKAGE_VERSION="" -DPACKAGE_URL="")
target_include_directories(sidplugin PRIVATE libsidplayfp/src libsidplayfp/src/builders/residfp-builder/residfp)
