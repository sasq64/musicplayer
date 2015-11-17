cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.uade)

add_subdirectory(uade)

include_directories(../.. uade/uade/src/frontends/include)

if(WIN32)
set(EXTRA_LIBS ws2_32)
endif()

add_library(uadeplugin UADEPlugin.cpp)
target_link_libraries(uadeplugin uade ${EXTRA_LIBS})

