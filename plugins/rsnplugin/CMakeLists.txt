cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.rsnplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

set(SOURCE_FILES RSNPlugin.cpp)

#include_directories()

add_library(rsnplugin ${SOURCE_FILES})

