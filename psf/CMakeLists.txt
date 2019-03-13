cmake_minimum_required(VERSION 3.5)
project(musicplayer)

add_library(psf STATIC psflib.c)
target_include_directories(psf PUBLIC include)
