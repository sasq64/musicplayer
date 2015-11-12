cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.uade)

SET(SOURCE_FILES
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
	bencodetools/bencode.c
)

if(NOT APPLE)
	SET(SOURCE_FILES ${SOURCE_FILES}
		uade/compat/strlrep.c
	)
endif()

include_directories(. uade/src uade/src/include uade/src/frontends/include uade/src/frontends/common)

#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-sizeof-pointer-memaccess")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fomit-frame-pointer -Wall -Wno-unused -Wno-format -Wmissing-prototypes -Wstrict-prototypes -fno-exceptions")


set(SOURCE_FILES ${SOURCE_FILES}
	#uade/src/main.c
	uade/src/newcpu.c
	uade/src/memory.c
	uade/src/custom.c
	uade/src/cia.c
	uade/src/audio.c
	uade/src/compiler.c
	uade/src/cpustbl.c
	uade/src/missing.c
	uade/src/sd-sound.c
	uade/src/md-support.c
	uade/src/cfgfile.c
	uade/src/fpp.c
	uade/src/debug.c
	uade/src/readcpu.c
	uade/src/cpudefs.c
	uade/src/cpuemu.c
	uade/src/uade.c
	#uade/src/uadeipc.c
	#uade/src/uadeutils.c
	#uade/src/unixatomic.c
	#uade/src/ossupport.c
	uade/src/uademain.c
	uade/src/sinctable.c
	uade/src/text_scope.c
	uade/src/socketpair.c
)

add_library(uade ${SOURCE_FILES})



