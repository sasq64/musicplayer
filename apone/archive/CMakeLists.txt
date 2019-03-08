cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.archive)

add_subdirectory(unrar)
if (NOT TARGET miniz)
	add_subdirectory(../miniz miniz)
endif()

set(SOURCE_FILES archive.cpp)

add_library(archive ${SOURCE_FILES})
target_link_libraries(archive PRIVATE coreutils unrar miniz)
target_compile_definitions(archive PRIVATE -DSILENT -DRARDLL)
