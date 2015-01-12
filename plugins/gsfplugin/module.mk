ifeq ($(GSFPLUGIN_INCLUDED),)
GSFPLUGIN_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

gsfplugin_FILES := $(THIS_DIR)GSFPlugin.cpp \
	$(THIS_DIR)playgsf/gsf.cpp \
	$(THIS_DIR)playgsf/VBA/GBA.cpp \
	$(THIS_DIR)playgsf/VBA/Globals.cpp \
	$(THIS_DIR)playgsf/VBA/Sound.cpp \
	$(THIS_DIR)playgsf/VBA/Util.cpp \
	$(THIS_DIR)playgsf/VBA/bios.cpp \
	$(THIS_DIR)playgsf/VBA/memgzio.c \
	$(THIS_DIR)playgsf/VBA/snd_interp.cpp \
	$(THIS_DIR)playgsf/VBA/unzip.cpp \
	$(THIS_DIR)playgsf/VBA/psftag.c

gsfplugin_FILES += $(THIS_DIR)playgsf/libresample-0.1.3/src/resample.c \
	$(THIS_DIR)playgsf/libresample-0.1.3/src/resamplesubs.c \
	$(THIS_DIR)playgsf/libresample-0.1.3/src/filterkit.c
	
gsfplugin_INCLUDES := $(THIS_DIR) $(THIS_DIR)playgsf $(THIS_DIR)playgsf/libresample-0.1.3/include

gsfplugin_CFLAGS := -DLINUX -DC_CORE -O

INCLUDES += $(THIS_DIR)/..

MODULES += gsfplugin

endif
