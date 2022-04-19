cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.tfmxplugin)

set(SOURCE_FILES TFMXPlugin.cpp tfmxplay.c)

add_library(tfmxplugin ${SOURCE_FILES})
target_link_libraries(tfmxplugin PRIVATE coreutils)
