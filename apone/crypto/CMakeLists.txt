cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.crypto)

add_library(crypto sha256.cpp md5.cpp solar-md5.cpp)
target_include_directories(crypto INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/..)
