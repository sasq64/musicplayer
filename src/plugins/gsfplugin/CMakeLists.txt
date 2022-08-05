cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.gsfplugin)

set(SOURCE_FILES
	GSFPlugin.cpp
	playgsf/gsf.cpp
	playgsf/VBA/GBA.cpp
	playgsf/VBA/Globals.cpp
	playgsf/VBA/Sound.cpp
	playgsf/VBA/Util.cpp
	playgsf/VBA/bios.cpp
	playgsf/VBA/memgzio.c
	playgsf/VBA/snd_interp.cpp
	playgsf/VBA/unzip.cpp
	playgsf/VBA/psftag.c
    playgsf/libresample-0.1.3/src/resample.c
    playgsf/libresample-0.1.3/src/resamplesubs.c
    playgsf/libresample-0.1.3/src/filterkit.c
)

#if(APPLE) # Apple clang chokes on this file with optimization on
#	set_source_files_properties(playgsf/VBA/GBA.cpp COMPILE_FLAGS -O0)
#endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-parentheses-equality -Wno-dangling-else")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-parentheses-equality -Wno-dangling-else")
endif()

#find_package(ZLIB REQUIRED)

add_library(gsf STATIC ${SOURCE_FILES})
target_compile_definitions(gsf PRIVATE LINUX C_CORE)
#NO_INTERPOLATION)
target_include_directories(gsf PRIVATE ${ZLIB_INCLUDE_DIRS} playgsf playgsf/libresample-0.1.3/include ..)
target_link_libraries(gsf PRIVATE psf coreutils ${ZLIB_LIBRARIES})

add_library(gsfplugin OBJECT gsfplugin_register.cpp)
target_link_libraries(gsfplugin PRIVATE gsf)
