cmake_minimum_required(VERSION 3.0)
project(cpp-mods.archive)

add_subdirectory(unrar)
add_subdirectory(miniz)

set(SOURCE_FILES archive.cpp)

add_library(archive ${SOURCE_FILES})
target_include_directories(archive PRIVATE . PUBLIC ..)
target_link_libraries(archive PRIVATE coreutils unrar miniz)
target_compile_definitions(archive PRIVATE -DSILENT -DRARDLL)
