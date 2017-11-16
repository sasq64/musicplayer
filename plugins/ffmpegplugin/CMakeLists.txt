cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.ffmpegplugin)
#include(FindPkgConfig)
set(SOURCE_FILES FFMPEGPlugin.cpp)

#pkg_search_module(AVFORMAT REQUIRED libavformat)
#pkg_search_module(SWSCALE REQUIRED libswscale)
#pkg_search_module(AVCODEC REQUIRED libavcodec)
#pkg_search_module(AVFILTER REQUIRED libavfilter)
#pkg_search_module(SWRESAMPLE REQUIRED libswresample)
#pkg_search_module(AVUTIL REQUIRED libavutil)

#set(FFMPEG_LIBRARIES ${AVFORMAT_LIBRARIES} ${SWSCALE_LIBRARIES} ${AVCODEC_LIBRARIES} ${AVFILTER_LIBRARIES} ${AVUTIL_LIBRARIES} ${SWRESAMPLE_LIBRARIES})
#set(FFMPEG_LIBRARY_DIRS ${AVFORMAT_LIBRARY_DIRS} ${SWSCALE_LIBRARY_DIRS})
#set(FFMPEG_INCLUDE_DIRS ${AVFORMAT_INCLUDE_DIRS} ${SWSCALE_INCLUDE_DIRS})

#link_directories(${FFMPEG_LIBRARY_DIRS})

add_library(ffmpegplugin ${SOURCE_FILES})
#target_include_directories(ffmpegplugin PRIVATE ${FFMPEG_INCLUDE_DIRS})
#target_link_libraries(ffmpegplugin PRIVATE ${FFMPEG_LIBRARIES})

