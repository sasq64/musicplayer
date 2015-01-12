ifeq ($(STSOUNDPLUGIN_INCLUDED),)
STSOUNDPLUGIN_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

stsound_DIRS := $(THIS_DIR)StSoundLibrary $(THIS_DIR)StSoundLibrary/LZH
stsound_FILES := $(THIS_DIR)StSoundPlugin.cpp
stsound_INCLUDES := $(THIS_DIR)../.. $(MODULE_DIR)

INCLUDES += $(THIS_DIR)/..

MODULES += stsound

endif
