cmake_minimum_required(VERSION 3.0)
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

add_library(stsound ${SOURCE_FILES})
target_link_libraries(stsound PRIVATE coreutils)

add_library(stsoundplugin OBJECT stsoundplugin_register.cpp)
target_link_libraries(stsoundplugin PRIVATE stsound)

