cmake_minimum_required(VERSION 3.6)
project(cpp-mods)

foreach(PLUGIN ${MUSICPLAYER_PLUGINS})
    add_subdirectory(${PLUGIN})
endforeach()

