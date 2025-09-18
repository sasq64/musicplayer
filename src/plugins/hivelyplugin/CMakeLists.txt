cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.hivelyplugin)

add_library(hivelyplugin STATIC HivelyPlugin.cpp hvl_replay.c)
target_link_libraries(hivelyplugin PRIVATE coreutils)

