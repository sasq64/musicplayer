ifeq ($(MUSIC_PLAYER_INCLUDED),)
MUSIC_PLAYER_INCLUDED = 1
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

CPP_MODS := $(realpath $(CPP_MODS))
ifeq ($(CPP_MODS),)
  CPP_MODS := $(realpath ../cpp-mods)
endif

ifeq ($(CPP_MODS),)
  $(error Can not find 'cpp-mods'. Please set CPP_MODS to point to that directory)
endif

#INCLUDES += $(THIS_DIR)
INCLUDES += $(THIS_DIR)..
#include $(CPP_MODS)/coreutils/module.mk

endif