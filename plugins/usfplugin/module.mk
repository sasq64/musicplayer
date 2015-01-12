ifeq ($(USFPLUGIN_INCLUDED),)
USFPLUGIN_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

usfplugin_FILES := $(THIS_DIR)resampler.c \
		$(THIS_DIR)USFPlugin.cpp \
		$(THIS_DIR)lazyusf/psflib.c \
		$(THIS_DIR)lazyusf/audio.c \
		$(THIS_DIR)lazyusf/cpu.c \
		$(THIS_DIR)lazyusf/dma.c \
		$(THIS_DIR)lazyusf/exception.c \
		$(THIS_DIR)lazyusf/interpreter_cpu.c \
		$(THIS_DIR)lazyusf/interpreter_ops.c \
		$(THIS_DIR)lazyusf/main.c \
		$(THIS_DIR)lazyusf/memory.c \
		$(THIS_DIR)lazyusf/pif.c \
		$(THIS_DIR)lazyusf/registers.c \
		$(THIS_DIR)lazyusf/tlb.c \
		$(THIS_DIR)lazyusf/usf.c \
		$(THIS_DIR)lazyusf/rsp/rsp.c \
		$(THIS_DIR)lazyusf/rsp_hle/alist.c \
		$(THIS_DIR)lazyusf/rsp_hle/alist_audio.c \
		$(THIS_DIR)lazyusf/rsp_hle/alist_naudio.c \
		$(THIS_DIR)lazyusf/rsp_hle/alist_nead.c \
		$(THIS_DIR)lazyusf/rsp_hle/audio.c \
		$(THIS_DIR)lazyusf/rsp_hle/cicx105.c \
		$(THIS_DIR)lazyusf/rsp_hle/jpeg.c \
		$(THIS_DIR)lazyusf/rsp_hle/hle.c \
		$(THIS_DIR)lazyusf/rsp_hle/memory.c \
		$(THIS_DIR)lazyusf/rsp_hle/mp3.c \
		$(THIS_DIR)lazyusf/rsp_hle/musyx.c \
		$(THIS_DIR)lazyusf/rsp_hle/plugin.c


usfplugin_CFLAGS = -O3 -ffast-math -finline-functions -funswitch-loops
# -ftree-vectorizer-verbose=1 -fpredictive-commoning -fgcse-after-reload -ftree-vectorize -fipa-cp-clone
#-DARCH_MIN_ARM_NEON -mfpu=neon 
usfplugin_INCLUDES := $(THIS_DIR) $(THIS_DIR)/lazyusf $(THIS_DIR)/lazyusf/rsp_hle
		
INCLUDES += $(THIS_DIR)/..

MODULES += usfplugin

endif
