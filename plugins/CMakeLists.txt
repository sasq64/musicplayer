cmake_minimum_required(VERSION 3.6)
project(cpp-mods)

foreach(PLUGIN ${MUSICPLAYER_PLUGINS})
    add_subdirectory(${PLUGIN})
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN}/${PLUGIN}_register.cpp)
        set(EXTRA_FILES ${EXTRA_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN}/${PLUGIN}_register.cpp)
    endif()
endforeach()

add_library(plugin_register OBJECT ${EXTRA_FILES})
add_library(all_plugins INTERFACE)
target_link_libraries(all_plugins INTERFACE plugin_register ${MUSICPLAYER_PLUGINS})
set(PLUGIN_EXTRA_FILES ${EXTRA_FILES} PARENT_SCOPE)

