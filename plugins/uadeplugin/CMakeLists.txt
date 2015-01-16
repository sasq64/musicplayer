cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.uade)

add_subdirectory(uade)

#include_directories(. ../.. uade/uade/src/include uade/uade/src/frontends/include uade/uade/src/frontends/common)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

add_library(uadeplugin UADEPlugin.cpp)
target_link_libraries(uadeplugin uade)

