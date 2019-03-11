cmake_minimum_required(VERSION 3.5)
project(cpp-mods.musicplayer.uade)

if(WIN32)
    set(EXTRA_LIBS ws2_32)
else()
    set(EXTRA_LIBS pthread)
endif()

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

if((NOT APPLE) AND (NOT WIN32))
    SET(UADE_SOURCES ${UADE_SOURCES}
        uade/compat/strlrep.c
    )
endif()


add_executable(build68k uade/src/build68k.c)
target_include_directories(build68k PRIVATE uade/src uade/src/include)
add_executable(gencpu uade/src/gencpu.c uade/src/readcpu.c ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c uade/src/missing.c)
target_include_directories(gencpu PRIVATE uade/src uade/src/include)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c
    COMMAND build68k < ${CMAKE_CURRENT_SOURCE_DIR}/uade/src/table68k > ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c
    DEPENDS $<TARGET_FILE:build68k>
    COMMENT "Running build68k")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/cpuemu.c ${CMAKE_CURRENT_BINARY_DIR}/cputbl.h ${CMAKE_CURRENT_BINARY_DIR}/cpustbl.c
    COMMAND gencpu
    DEPENDS $<TARGET_FILE:gencpu>
    COMMENT "Running gencpu")

add_library(uade OBJECT ${UADE_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/cpuemu.c ${CMAKE_CURRENT_BINARY_DIR}/cpudefs.c ${CMAKE_CURRENT_BINARY_DIR}/cpustbl.c)
target_link_libraries(uade PRIVATE ws2_32)
target_compile_definitions(uade PRIVATE -DPART_1 -DPART_2 -DPART_3 -DPART_4 -DPART_5 -DPART_6 -DPART_7 -DPART_8)
#target_compile_options(uade PRIVATE -Wno-format -Wno-implicit-function-declaration)
target_include_directories(uade PRIVATE
    bencode/include
    uade/
    uade/src/
    uade/src/include/
    uade/src/frontends/include/
    uade/src/frontends/common/
)

add_library(uadeplugin STATIC UADEPlugin.cpp)
target_link_libraries(uadeplugin PRIVATE uade coreutils ${EXTRA_LIBS})
target_include_directories(uadeplugin PRIVATE uade/src/frontends/include)

