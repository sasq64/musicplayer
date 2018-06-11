cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

set(APONE ../apone/mods)

include_directories(. ${APONE})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")

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
	mp3plugin
	ndsplugin
	openmptplugin
	rsnplugin
	s98plugin
	sc68plugin
	stsoundplugin
	tedplugin
	uadeplugin
	usfplugin
	viceplugin
	v2plugin
    # Obsolete
    # sexypsfplugin
    # modplugin
)

add_subdirectory(plugins)
add_subdirectory(${APONE}/coreutils coreutils)
add_subdirectory(${APONE}/crypto crypto)
add_subdirectory(${APONE}/audioplayer audioplayer)
add_subdirectory(${APONE}/archive archive)

add_executable(play main.cpp ${PLUGIN_EXTRA_FILES})
target_link_libraries(play ${MUSICPLAYER_PLUGINS} coreutils audioplayer crypto archive pthread)
set_property(TARGET play PROPERTY CXX_STANDARD 14)
set_property(TARGET play PROPERTY CXX_STANDARD_REQUIRED ON)

