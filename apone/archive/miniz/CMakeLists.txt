cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.miniz)

set(SOURCE_FILES miniz.c)
add_library(miniz miniz.c)
