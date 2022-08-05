cmake_minimum_required(VERSION 3.0)
project(cpp-mods.musicplayer.mdxplugin)

set(SOURCE_FILES
    mdxmini/src/mdxmini.c
    mdxmini/src/mdx2151.c
    mdxmini/src/mdxmml_ym2151.c
    mdxmini/src/pdxfile.c
    mdxmini/src/mdxfile.c
    mdxmini/src/pcm8.c
    mdxmini/src/ym2151.c
    mdxmini/src/nlg.c
)

add_library(mdxmini MDXPlugin.cpp ${SOURCE_FILES})
target_include_directories(mdxmini PRIVATE mdxmini/src)
target_link_libraries(mdxmini PRIVATE coreutils)

add_library(mdxplugin OBJECT mdxplugin_register.cpp)
target_link_libraries(mdxplugin PRIVATE mdxmini)
