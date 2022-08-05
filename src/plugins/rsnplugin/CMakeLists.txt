cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.rsnplugin)

set(SOURCE_FILES RSNPlugin.cpp)
add_library(rsn RSNPlugin.cpp)
target_link_libraries(rsn PRIVATE archive coreutils)

add_library(rsnplugin OBJECT rsnplugin_register.cpp)
target_link_libraries(rsnplugin PRIVATE rsn)


