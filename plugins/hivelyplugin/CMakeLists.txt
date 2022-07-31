cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.hivelyplugin)

add_library(hivelyplugin_impl STATIC HivelyPlugin.cpp hvl_replay.c)
target_link_libraries(hivelyplugin_impl PRIVATE coreutils)

add_library(hivelyplugin OBJECT hivelyplugin_register.cpp)
target_link_libraries(hivelyplugin PRIVATE hivelyplugin_impl)
