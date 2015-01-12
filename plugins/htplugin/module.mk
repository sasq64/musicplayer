ifeq ($(HTPLUGIN_INCLUDED),)
HTPLUGIN_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

htplugin_FILES := $(THIS_DIR)HTPlugin.cpp \
	$(THIS_DIR)ht/arm.c \
	$(THIS_DIR)ht/dcsound.c \
	$(THIS_DIR)ht/psflib.c \
	$(THIS_DIR)ht/satsound.c \
	$(THIS_DIR)ht/sega.c \
	$(THIS_DIR)ht/yam.c \
	$(THIS_DIR)ht/m68k/m68kops.c \
	$(THIS_DIR)ht/m68k/m68kcpu.c

htplugin_INCLUDES := $(THIS_DIR)
#htplugin_LDFLAGS := -Wl,--fix-cortex-a8
htplugin_CFLAGS := -DEMU_COMPILE -DEMU_LITTLE_ENDIAN -DUSE_M68K -DHAVE_STDINT_H -DLSB_FIRST -DHAVE_MPROTECT -O3 -ffast-math -finline-functions -funswitch-loops
#htplugin_CFLAGS += -mfpu=neon-ftree-vectorizer-verbose=1 -fpredictive-commoning -fgcse-after-reload -ftree-vectorize -fipa-cp-clone

INCLUDES += $(THIS_DIR)/..

MODULES += htplugin

endif
