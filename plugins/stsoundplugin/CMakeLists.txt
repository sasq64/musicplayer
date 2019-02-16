cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.stsoundplugin)

set(SOURCE_FILES
    StSoundPlugin.cpp
    StSoundLibrary/Ym2149Ex.cpp
    StSoundLibrary/YmMusic.cpp
    StSoundLibrary/YmUserInterface.cpp
    StSoundLibrary/Ymload.cpp
    StSoundLibrary/digidrum.cpp
    StSoundLibrary/LZH/LzhLib.cpp
)

add_library(stsoundplugin ${SOURCE_FILES})
target_link_libraries(stsoundplugin PRIVATE coreutils)

