cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.modplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

file(GLOB SOURCE_FILES modplug/*.cpp)
include_directories(modplug)

if(EMSCRIPTEN)
	set_source_files_properties(modplug/load_abc.cpp COMPILE_FLAGS -Os)
endif()

add_library(modplugin ModPlugin.cpp ${SOURCE_FILES})
