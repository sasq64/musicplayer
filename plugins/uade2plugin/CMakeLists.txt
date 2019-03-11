cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.uade)

#add_subdirectory(uade)


if(WIN32)
set(EXTRA_LIBS ws2_32)
endif()

set(SRC uade/src)


set(UADE_SOURCES
        uade/src/frontends/common/unixatomic.c
        uade/src/frontends/common/uadeipc.c
        uade/src/frontends/common/amifilemagic.c
        uade/src/frontends/common/eagleplayer.c
        uade/src/frontends/common/effects.c
        uade/src/frontends/common/uadecontrol.c
        uade/src/frontends/common/uadeconf.c
        uade/src/frontends/common/uadestate.c
        uade/src/frontends/common/uadeutils.c
        uade/src/frontends/common/md5.c
        uade/src/frontends/common/ossupport.c
        uade/src/frontends/common/rmc.c
        uade/src/frontends/common/songdb.c
        uade/src/frontends/common/songinfo.c
        uade/src/frontends/common/vparray.c
        uade/src/frontends/common/support.c
        uade/src/frontends/common/fifo.c
        uade/src/newcpu.c
        uade/src/memory.c
        uade/src/custom.c
        uade/src/cia.c
        uade/src/audio.c
        uade/src/compiler.c
        uade/src/missing.c
        uade/src/sd-sound.c
        uade/src/md-support.c
        uade/src/cfgfile.c
        uade/src/fpp.c
        uade/src/debug.c
        uade/src/readcpu.c
        uade/src/uade.c
        uade/src/uademain.c
        uade/src/sinctable.c
        uade/src/text_scope.c
        uade/src/socketpair.c
        bencode/bencode.c
)

add_executable(build68k ${SRC}/build68k.c)
target_include_directories(build68k PRIVATE uade/src uade/src/include)
add_executable(gencpu ${SRC}/gencpu.c ${SRC}/readcpu.c ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c ${SRC}/missing.c)
target_include_directories(gencpu PRIVATE uade/src uade/src/include)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build68k < ${CMAKE_CURRENT_SOURCE_DIR}/${SRC}/table68k > ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/build68k
    COMMENT "Running build68k")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/cpuemu.c ${CMAKE_CURRENT_BINARY_DIR}/cputbl.h ${CMAKE_CURRENT_BINARY_DIR}/cpustbl.c
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gencpu
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gencpu
    COMMENT "Running gencpu")

add_library(uade STATIC ${UADE_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/cpuemu.c ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c ${CMAKE_CURRENT_BINARY_DIR}/cpustbl.c)
target_compile_definitions(uade PRIVATE -DPART_1 -DPART_2 -DPART_3 -DPART_4 -DPART_5 -DPART_6 -DPART_7 -DPART_8)
target_compile_options(uade PRIVATE -Wno-format -Wno-implicit-function-declaration)
target_include_directories(uade PRIVATE
	bencode/include
	uade/
	uade/src/
	uade/src/include/
	uade/src/frontends/include/
	uade/src/frontends/common/
)

add_library(uade2plugin STATIC UADEPlugin.cpp)
target_link_libraries(uade2plugin PRIVATE uade pthread coreutils ${EXTRA_LIBS})
target_include_directories(uade2plugin PRIVATE ../.. uade/src/frontends/include)

