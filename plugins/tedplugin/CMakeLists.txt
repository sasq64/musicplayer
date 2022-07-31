cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.tedplugin)

set(TEDPLAY_FILES tedplay/Audio.cpp tedplay/CbmTune.cpp tedplay/Filter.cpp tedplay/Tedmem.cpp tedplay/Cpu.cpp tedplay/Sid.cpp tedplay/Tedsound.cpp tedplay/tedplay.cpp
)

set(SOURCE_FILES TEDPlugin.cpp ${TEDPLAY_FILES})
add_library(tedplay ${SOURCE_FILES})
target_link_libraries(tedplay PRIVATE coreutils)

add_library(tedplugin OBJECT tedplugin_register.cpp)
target_link_libraries(tedplugin PRIVATE tedplay)
