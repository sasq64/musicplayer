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

#include_directories()

add_library(stsoundplugin ${SOURCE_FILES})

