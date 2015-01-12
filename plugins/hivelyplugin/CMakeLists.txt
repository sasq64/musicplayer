cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.hivelyplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

set(SOURCE_FILES HivelyPlugin.cpp hvl_replay.c)

add_library(hivelyplugin ${SOURCE_FILES})

