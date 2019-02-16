cmake_minimum_required(VERSION 2.8.4)
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

add_library(mdxplugin MDXPlugin.cpp ${SOURCE_FILES})
target_include_directories(mdxplugin PRIVATE mdxmini/src)
target_link_libraries(mdxplugin PRIVATE coreutils)
