cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.rsnplugin)



set(SOURCE_FILES RSNPlugin.cpp)

#include_directories()

add_library(rsnplugin ${SOURCE_FILES})

