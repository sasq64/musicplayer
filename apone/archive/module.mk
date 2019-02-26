ifeq ($(ARCHIVE_INCLUDED),)
ARCHIVE_INCLUDED = 1

THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

INCLUDES += $(THIS_DIR)..
archive_DIRS := $(THIS_DIR)ziplib

#LOCAL_FILES = unrar/filestr.cpp unrar/recvol.cpp unrar/rs.cpp unrar/scantree.cpp
LOCAL_FILES := unrar/filestr.cpp unrar/scantree.cpp unrar/dll.cpp
LOCAL_FILES += unrar/rar.cpp unrar/strlist.cpp unrar/strfn.cpp unrar/pathfn.cpp unrar/savepos.cpp unrar/smallfn.cpp unrar/global.cpp unrar/file.cpp unrar/filefn.cpp unrar/filcreat.cpp \
	unrar/archive.cpp unrar/arcread.cpp unrar/unicode.cpp unrar/system.cpp unrar/isnt.cpp unrar/crypt.cpp unrar/crc.cpp unrar/rawread.cpp unrar/encname.cpp \
	unrar/resource.cpp unrar/match.cpp unrar/timefn.cpp unrar/rdwrfn.cpp unrar/consio.cpp unrar/options.cpp unrar/ulinks.cpp unrar/errhnd.cpp unrar/rarvm.cpp \
	unrar/rijndael.cpp unrar/getbits.cpp unrar/sha1.cpp unrar/extinfo.cpp unrar/extract.cpp unrar/volume.cpp unrar/list.cpp unrar/find.cpp unrar/unpack.cpp unrar/cmddata.cpp

archive_FILES := $(THIS_DIR)archive.cpp $(addprefix $(THIS_DIR),$(LOCAL_FILES)) 

archive_CFLAGS := -DSILENT -DRARDLL -I$(THIS_DIR)rar

MODULES += archive

endif



