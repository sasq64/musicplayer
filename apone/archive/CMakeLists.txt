cmake_minimum_required(VERSION 3.12)
project(cpp-mods.archive)

# RAR support compiles in the bundled unrar sources. An application that
# already links its own copy of unrar — as a Rust host using the `unrar` crate
# does — would then hit duplicate symbols at link time, so it can be left out;
# `Archive::open` returns null for RAR files instead. Set before adding this
# directory.
if(NOT DEFINED ARCHIVE_WITH_UNRAR)
    set(ARCHIVE_WITH_UNRAR ON)
endif()

if(ARCHIVE_WITH_UNRAR)
    add_subdirectory(unrar)
endif()
add_subdirectory(miniz)

set(SOURCE_FILES archive.cpp)

add_library(archive ${SOURCE_FILES})
target_include_directories(archive PRIVATE . PUBLIC ..)
target_compile_definitions(archive PRIVATE -DSILENT)

if(ARCHIVE_WITH_UNRAR)
    target_link_libraries(archive PRIVATE coreutils unrar miniz)
    target_compile_definitions(archive PRIVATE -DRARDLL)
else()
    target_link_libraries(archive PRIVATE coreutils miniz)
    target_compile_definitions(archive PRIVATE -DARCHIVE_NO_UNRAR)
endif()
