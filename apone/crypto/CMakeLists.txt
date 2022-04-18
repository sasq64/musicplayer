cmake_minimum_required(VERSION 3.0)
project(apone-cpp.crypto)

set(SOURCE_FILES src/crypto/sha256.cpp src/crypto/md5.cpp src/crypto/solar-md5.c)

add_library(crypto ${SOURCE_FILES})
target_include_directories(crypto PUBLIC src)
add_library(apone::crypto ALIAS crypto)
