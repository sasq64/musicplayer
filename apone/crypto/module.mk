ifeq ($(CRYPTO_INCLUDED),)
CRYPTO_INCLUDED = 1

THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

INCLUDES += $(THIS_DIR)..
crypto_FILES := $(THIS_DIR)sha256.cpp $(THIS_DIR)md5.cpp $(THIS_DIR)solar-md5.c

MODULES += crypto

endif