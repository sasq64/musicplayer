ifeq ($(AUDIO_PLAYER_INCLUDED),)
AUDIO_PLAYER_INCLUDED = 1

THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
LIBS += -ldl

INCLUDES += $(THIS_DIR)..
audioplayer_FILES := $(THIS_DIR)audioplayer.cpp

ifneq ($(SDL_AUDIO),)
  LIBS += `sdl-config --libs`
  audioplayer_CFLAGS := `sdl-config --cflags`
  CFLAGS += -DSDL_AUDIO
  audioplayer_FILES += $(THIS_DIR)player_sdl.cpp
else ifeq ($(HOST),linux)
  LIBS += -lasound
  audioplayer_FILES += $(THIS_DIR)player_linux.cpp
else ifeq ($(HOST),raspberrypi)
  LIBS += -lasound
  audioplayer_FILES += $(THIS_DIR)player_linux.cpp
else ifeq ($(HOST),android)
  LIBS += -lOpenSLES
  audioplayer_FILES += $(THIS_DIR)player_sl.cpp
else
  LIBS += `sdl-config --libs`
  audioplayer_CFLAGS := `sdl-config --cflags`
  CFLAGS += -DSDL_AUDIO
  audioplayer_FILES += $(THIS_DIR)player_sdl.cpp
endif

MODULES += audioplayer

endif