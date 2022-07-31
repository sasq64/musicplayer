cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.tfmxplugin)

set(SOURCE_FILES TFMXPlugin.cpp tfmxplay.c player.c audio.c)

add_library(tfmx ${SOURCE_FILES})
target_link_libraries(tfmx PRIVATE coreutils)

add_library(tfmxplugin OBJECT tfmxplugin_register.cpp)
target_link_libraries(tfmxplugin PRIVATE tfmx)
