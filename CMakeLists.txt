cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

include_directories(. ../apone/mods)


set(MUSICPLAYER_PLUGINS
	adplugin
	aoplugin
	ayflyplugin
	ffmpegplugin
	gmeplugin
	gsfplugin
	heplugin
	hivelyplugin
	htplugin
	mdxplugin
	modplugin
	mp3plugin
	ndsplugin
	openmptplugin
	rsnplugin
	s98plugin
	sc68plugin
	sexypsfplugin
	stsoundplugin
	tedplugin
	uadeplugin
	usfplugin
	viceplugin
)

add_subdirectory(plugins)
add_subdirectory(../apone/mods/coreutils coreutils)
add_subdirectory(../apone/mods/crypto crypto)
add_subdirectory(../apone/mods/audioplayer audioplayer)
add_subdirectory(../apone/mods/archive archive)

add_executable(musictest main.cpp ${PLUGIN_EXTRA_FILES})
target_link_libraries(musictest ${MUSICPLAYER_PLUGINS} coreutils audioplayer crypto archive pthread)
set_property(TARGET musictest PROPERTY CXX_STANDARD 14)
set_property(TARGET musictest PROPERTY CXX_STANDARD_REQUIRED ON)

