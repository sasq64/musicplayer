cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.s98plugin)


set(SOURCE_FILES
	m_s98/device/s98fmgen.cpp
	m_s98/device/s98mame.cpp
	m_s98/device/s98opll.cpp
	m_s98/device/s98sng.cpp
	m_s98/device/emu2413/emu2413.c
	m_s98/device/mame/fmopl.cpp
	m_s98/device/mame/ymf262.cpp
	m_s98/device/s_logtbl.c
	m_s98/device/s_sng.c
	m_s98/m_s98.cpp
	m_s98/device/fmgen/file.cpp
	m_s98/device/fmgen/fmgen.cpp
	m_s98/device/fmgen/fmtimer.cpp
	m_s98/device/fmgen/opm.cpp
	m_s98/device/fmgen/opna.cpp
	m_s98/device/fmgen/psg.cpp

)

include_directories(m_s98)
#add_definitions(-DDISABLE_AUDIO)
#find_package(ZLIB REQUIRED)
#include_directories(${ZLIB_INCLUDE_DIRS})

add_library(s98plugin S98Plugin.cpp ${SOURCE_FILES})
target_link_libraries(s98plugin ${ZLIB_LIBRARIES})
