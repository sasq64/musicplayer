cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.unrar)

set(SOURCE_FILES
	filestr.cpp
	scantree.cpp
	dll.cpp
	#rar.cpp
	strlist.cpp
	strfn.cpp
	pathfn.cpp
	savepos.cpp
	smallfn.cpp
	global.cpp
	file.cpp
	filefn.cpp
	filcreat.cpp
	archive.cpp
	arcread.cpp
	unicode.cpp
	system.cpp
	crypt.cpp
	crc.cpp
	rawread.cpp
	encname.cpp
	#resource.cpp
	match.cpp
	timefn.cpp
	rdwrfn.cpp
	consio.cpp
	options.cpp
	ulinks.cpp
	errhnd.cpp
	rarvm.cpp
	rijndael.cpp
	getbits.cpp
	sha1.cpp
	extinfo.cpp
	extract.cpp
	volume.cpp
	list.cpp
	find.cpp
	unpack.cpp
	cmddata.cpp
)
if(WIN32)
  set(SOURCE_FILES ${SOURCE_FILES}
  	isnt.cpp
  )
endif()


#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-logical-op-parentheses -Wno-dangling-else -Wno-switch")

add_definitions(-DSILENT -DRARDLL -DLITTLE_ENDIAN)
add_library(unrar ${SOURCE_FILES})

