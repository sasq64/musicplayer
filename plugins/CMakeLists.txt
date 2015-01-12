cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods)

foreach(PLUGIN ${MUSICPLAYER_PLUGINS})
    add_subdirectory(${PLUGIN})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN}/${PLUGIN}_register.cpp)
		set(EXTRA_FILES ${EXTRA_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN}/${PLUGIN}_register.cpp)		
	endif()
endforeach()

message("PLUGIN XFILES:" ${EXTRA_FILES})

set(SOURCE_FILES ${SOURCE_FILES} ${EXTRA_FILES} PARENT_SCOPE)

