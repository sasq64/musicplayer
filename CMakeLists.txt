cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")


include_directories(.)

add_library(musicplayer .cpp)
