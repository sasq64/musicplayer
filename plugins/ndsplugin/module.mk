ifeq ($(NDSPLUGIN_INCLUDED),)
NDSPLUGIN_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ndsplugin_FILES := $(THIS_DIR)NDSPlugin.cpp \
	$(THIS_DIR)nds/vio2sf/vio2sf.c \
	$(THIS_DIR)nds/vio2sf/desmume/arm_instructions.c \
	$(THIS_DIR)nds/vio2sf/desmume/armcpu.c \
	$(THIS_DIR)nds/vio2sf/desmume/bios.c \
	$(THIS_DIR)nds/vio2sf/desmume/cp15.c \
	$(THIS_DIR)nds/vio2sf/desmume/FIFO.c \
	$(THIS_DIR)nds/vio2sf/desmume/GPU.c \
	$(THIS_DIR)nds/vio2sf/desmume/matrix.c \
	$(THIS_DIR)nds/vio2sf/desmume/mc.c \
	$(THIS_DIR)nds/vio2sf/desmume/MMU.c \
	$(THIS_DIR)nds/vio2sf/desmume/NDSSystem.c \
	$(THIS_DIR)nds/vio2sf/desmume/SPU.c \
	$(THIS_DIR)nds/vio2sf/desmume/thumb_instructions.c
	
ndsplugin_CFLAGS := -DLSB_FIRST -DHAVE_STDINT_H -D_strnicmp=strncasecmp -O3 -funroll-all-loops
ndsplugin_INCLUDES := $(THIS_DIR)/nds/vio2sf $(THIS_DIR)/nds $(THIS_DIR)/nds/vio2sf/desmume

INCLUDES += $(THIS_DIR)/..

MODULES += ndsplugin

endif
