cmake_minimum_required(VERSION 3.5)
project(musicplayer)

add_library(psf STATIC psflib.c)
target_link_libraries(psf PRIVATE coreutils ${ZLIB_LIBRARIES})
target_include_directories(psf PUBLIC include PRIVATE ${ZLIB_INCLUDE_DIRS})
