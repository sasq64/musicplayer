cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.uade)

SET(SOURCE_FILES
	UADEPlugin.cpp
	uade/src/frontends/common/unixatomic.c
	uade/src/frontends/common/uadeipc.c
	uade/src/frontends/common/amifilemagic.c
	uade/src/frontends/common/eagleplayer.c
	uade/src/frontends/common/unixwalkdir.c
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
	uade/src/frontends/common/strlrep.c
	bencodetools/bencode.c
)
#ifeq ($(HOST),linux)
#	uade_FILES += $(FE)strlrep.c
#endif

include_directories(. ../.. uade/src/include uade/src/frontends/include uade/src/frontends/common)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-sizeof-pointer-memaccess")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

add_library(uadeplugin ${SOURCE_FILES})
