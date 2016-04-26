cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.ffmpegplugin)

set(SOURCE_FILES FFMPEGPlugin.cpp)
link_directories(
    /usr/local/lib
)
find_library(ICONV_LIBRARY iconv REQUIRED)

find_library(AVCODEC_LIBRARY avcodec REQUIRED)
find_library(AVFORMAT_LIBRARY avformat REQUIRED)
find_library(AVUTIL_LIBRARY avutil REQUIRED)
find_library(AVDEVICE_LIBRARY avdevice REQUIRED)
find_library(AVFILTER_LIBRARY avfilter REQUIRED)
find_library(AVRESAMPLE_LIBRARY swresample REQUIRED)

find_path(AVFORMAT_PATH libavformat/avformat.h)

find_library(VDA_PATH VideoDecodeAcceleration REQUIRED)
find_library(COREMED_PATH CoreMedia REQUIRED)
find_library(COREVID_PATH CoreVideo REQUIRED)
find_library(COREFND_PATH CoreFoundation REQUIRED)
find_library(VTB_PATH VideoToolbox REQUIRED)
set(FRAMEWORKS ${VTB_PATH} ${VDA_PATH} ${COREVID_PATH} ${COREMED_PATH} ${COREFND_PATH})
#set(FFMPEG ${AVCODEC_LIBRARY} ${ICONV_LIBRARY} ${AVFORMAT_LIBRARY} ${AVUTIL_LIBRARY})

set(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS} -L/usr/local/lib)


#set(FFMPEG ${AVCODEC_LIBRARY} ${AVUTIL_LIBRARY} ${AVFORMAT_LIBRARY} ${AVDEVICE_LIBRARY} ${AVFILTER_LIBRARY} ${AVRESAMPLE_LIBRARY})
set(FFMPEG avcodec avutil avformat swresample)

include_directories(${AVFORMAT_PATH})

add_library(ffmpegplugin ${SOURCE_FILES})
target_link_libraries(ffmpegplugin ${FRAMEWORKS} ${FFMPEG} ${ICONV_LIBRARY})

