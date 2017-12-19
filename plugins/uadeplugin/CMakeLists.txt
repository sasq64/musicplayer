cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.uade)

add_subdirectory(uade)


if(WIN32)
set(EXTRA_LIBS ws2_32)
endif()

add_library(uadeplugin UADEPlugin.cpp)
target_link_libraries(uadeplugin PRIVATE uade ${EXTRA_LIBS})
target_include_directories(uadeplugin PRIVATE ../.. uade/uade/src/frontends/include)

