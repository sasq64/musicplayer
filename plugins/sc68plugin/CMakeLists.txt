cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.sc68plugin)

set(SOURCE_FILES
    SC68Plugin.cpp
    file68/src/endian68.c
    file68/src/error68.c
    file68/src/file68.c
    file68/src/gzip68.c
    file68/src/ice68.c
    file68/src/init68.c
    file68/src/istream68.c
    file68/src/istream68_ao.c
    file68/src/istream68_curl.c
    file68/src/istream68_fd.c
    file68/src/istream68_file.c
    file68/src/istream68_mem.c
    file68/src/istream68_null.c
    file68/src/istream68_z.c
    file68/src/msg68.c
    file68/src/option68.c
    file68/src/registry68.c
    file68/src/rsc68.c
    file68/src/string68.c
    file68/src/url68.c
    libsc68/api68.c
    libsc68/conf68.c
    libsc68/emu68/emu68.c
    libsc68/emu68/error68.c
    libsc68/emu68/getea68.c
    libsc68/emu68/inst68.c
    libsc68/emu68/ioplug68.c
    libsc68/emu68/line0_68.c
    libsc68/emu68/line1_68.c
    libsc68/emu68/line2_68.c
    libsc68/emu68/line3_68.c
    libsc68/emu68/line4_68.c
    libsc68/emu68/line5_68.c
    libsc68/emu68/line6_68.c
    libsc68/emu68/line7_68.c
    libsc68/emu68/line8_68.c
    libsc68/emu68/line9_68.c
    libsc68/emu68/lineA_68.c
    libsc68/emu68/lineB_68.c
    libsc68/emu68/lineC_68.c
    libsc68/emu68/lineD_68.c
    libsc68/emu68/lineE_68.c
    libsc68/emu68/lineF_68.c
    libsc68/emu68/mem68.c
    libsc68/emu68/table68.c
    libsc68/io68/io68.c
    libsc68/io68/mfp_io.c
    libsc68/io68/mfpemul.c
    libsc68/io68/mw_io.c
    libsc68/io68/mwemul.c
    libsc68/io68/paula_io.c
    libsc68/io68/paulaemul.c
    libsc68/io68/shifter_io.c
    libsc68/io68/ym_blep.c
    libsc68/io68/ym_dump.c
    libsc68/io68/ym_io.c
    libsc68/io68/ym_puls.c
    libsc68/io68/ymemul.c
    libsc68/libsc68.c
    libsc68/mixer68.c
    unice68/unice68_native.c
)

#find_package(ZLIB REQUIRED)

add_library(sc68plugin ${SOURCE_FILES})
target_include_directories(sc68plugin PRIVATE ${ZLIB_INCLUDE_DIRS} . libsc68/sc68 file68 file68/sc68 unice68 libsc68)
target_compile_definitions(sc68plugin PRIVATE -DHAVE_CONFIG_H)
target_link_libraries(sc68plugin PRIVATE coreutils ${ZLIB_LIBRARIES})
