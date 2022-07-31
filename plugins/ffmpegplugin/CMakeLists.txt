cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.ffmpegplugin)

set(SOURCE_FILES FFMPEGPlugin.cpp)
add_library(ffmpeg ${SOURCE_FILES})
target_link_libraries(ffmpeg PRIVATE coreutils)

add_library(ffmpegplugin OBJECT ffmpegplugin_register.cpp)
target_link_libraries(ffmpegplugin PRIVATE ffmpeg)
