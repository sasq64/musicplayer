ifeq ($(MP3PLUGIN_INCLUDED),)
MP3PLUGIN_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

#modplug_DIRS := $(THIS_DIR)modplug
mp3plugin_FILES := $(THIS_DIR)MP3Plugin.cpp
mp3plugin_INCLUDES := $(THIS_DIR)../.. $(MODULE_DIR)

LIBS += -lmpg123
CFLAGS += -I/usr/local/include

INCLUDES += $(THIS_DIR)/..

MODULES += mp3plugin

endif
