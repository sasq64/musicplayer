cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.ffmpegplugin)
set(SOURCE_FILES FFMPEGPlugin.cpp)
add_library(ffmpegplugin ${SOURCE_FILES})
target_link_libraries(ffmpegplugin PRIVATE coreutils)

