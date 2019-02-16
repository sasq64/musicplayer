cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.tedplugin)

set(TEDPLAY_FILES tedplay/Audio.cpp tedplay/CbmTune.cpp tedplay/Filter.cpp tedplay/Tedmem.cpp
	              tedplay/Cpu.cpp tedplay/Sid.cpp tedplay/Tedsound.cpp tedplay/tedplay.cpp
)

set(SOURCE_FILES TEDPlugin.cpp ${TEDPLAY_FILES})
add_library(tedplugin ${SOURCE_FILES})
target_link_libraries(tedplugin PRIVATE coreutils)
