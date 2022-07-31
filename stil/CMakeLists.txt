cmake_minimum_required(VERSION 3.5)
project(stil)

add_library(stil STATIC STIL.cpp)
target_link_libraries(stil PRIVATE coreutils crypto ${ZLIB_LIBRARIES})
target_include_directories(stil PUBLIC . PRIVATE ${ZLIB_INCLUDE_DIRS})
