cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.rsnplugin)

set(SOURCE_FILES RSNPlugin.cpp)
add_library(rsnplugin RSNPlugin.cpp)
target_link_libraries(rsnplugin PRIVATE archive coreutils)


