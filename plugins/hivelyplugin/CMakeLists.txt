cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.hivelyplugin)

set(SOURCE_FILES HivelyPlugin.cpp hvl_replay.c)

add_library(hivelyplugin ${SOURCE_FILES})
target_link_libraries(hivelyplugin PRIVATE coreutils)
