ifeq ($(HEPLUGIN_INCLUDED),)
HEPLUGIN_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

heplugin_FILES := $(THIS_DIR)HEPlugin.cpp \
	$(THIS_DIR)he/psx.c \
	$(THIS_DIR)he/ioptimer.c \
	$(THIS_DIR)he/iop.c \
	$(THIS_DIR)he/bios.c \
	$(THIS_DIR)he/r3000dis.c \
	$(THIS_DIR)he/r3000asm.c \
	$(THIS_DIR)he/r3000.c \
	$(THIS_DIR)he/vfs.c \
	$(THIS_DIR)he/spucore.c \
	$(THIS_DIR)he/spu.c \
	$(THIS_DIR)he/mkhebios.c \
	$(THIS_DIR)he/psf2fs.c \
	$(THIS_DIR)he/psflib.c
	
heplugin_INCLUDES := $(THIS_DIR) $(THIS_DIR)/he

heplugin_CFLAGS = -DEMU_COMPILE -DEMU_LITTLE_ENDIAN

htplugin_LDFLAGS := -Wl,--fix-cortex-a8

INCLUDES += $(THIS_DIR)/..

MODULES += heplugin

endif
