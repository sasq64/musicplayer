LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

MY_FMGEN_SRC = ./device/fmgen/file.cpp \
./device/fmgen/fmgen.cpp \
./device/fmgen/fmtimer.cpp \
./device/fmgen/opm.cpp \
./device/fmgen/opna.cpp \
./device/fmgen/psg.cpp

MY_M_S98_SRC = ./device/s98fmgen.cpp \
./device/s98mame.cpp \
./device/s98opll.cpp \
./device/s98sng.cpp \
./device/emu2413/emu2413.c \
./device/mame/fmopl.c \
./device/mame/ymf262.c \
./device/s_logtbl.c \
./device/s_sng.c \
./m_s98.cpp

LOCAL_MODULE    := m_s98
LOCAL_SRC_FILES := jni.cpp $(MY_M_S98_SRC) $(MY_FMGEN_SRC)
LOCAL_CFLAGS    += -DUSE_ZLIB -I$(LOCAL_PATH)/m_s98 -I.. -I$(LOCAL_PATH)/m_s98/device/fmgen
LOCAL_LDLIBS	+= -lm -lz -llog
LOCAL_ARM_MODE	:= arm

include $(BUILD_SHARED_LIBRARY)
