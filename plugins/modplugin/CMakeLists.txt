cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.modplugin)

file(GLOB SOURCE_FILES modplug/*.cpp)

add_library(modplug ModPlugin.cpp ${SOURCE_FILES})
target_include_directories(modplug PRIVATE modplug)
