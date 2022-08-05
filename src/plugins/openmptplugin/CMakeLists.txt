cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.openmptplugin)

file(GLOB SOUNDLIB_FILES CONFIGURE_DEPENDS openmpt/soundlib/*.cpp )
file(GLOB MPT_FILES CONFIGURE_DEPENDS openmpt/common/mpt*.cpp)

set(SOURCE_FILES
    OpenMPTPlugin.cpp
    ${MPT_FILES}
    openmpt/common/Logging.cpp
    openmpt/common/misc_util.cpp
    openmpt/common/serialization_utils.cpp
    openmpt/common/version.cpp
    openmpt/common/ComponentManager.cpp
    openmpt/libopenmpt/libopenmpt_c.cpp
    openmpt/libopenmpt/libopenmpt_cxx.cpp
    openmpt/libopenmpt/libopenmpt_impl.cpp
    openmpt/libopenmpt/libopenmpt_ext_impl.cpp
    ${SOUNDLIB_FILES}
)

add_library(openmpt ${SOURCE_FILES})
target_link_libraries(openmpt PRIVATE apone::coreutils ZLIB::ZLIB)
target_include_directories(openmpt PRIVATE openmpt openmpt/common .)
target_compile_definitions(openmpt PRIVATE -DLIBOPENMPT_BUILD -DOPENMPT_VERSION_REVISION=1 -DMPT_CHARSET_CUSTOMUTF8 -DMPT_WITH_ZLIB -DNO_PLUGINS -DNO_REVERB)

add_library(openmptplugin OBJECT openmptplugin_register.cpp)
target_link_libraries(openmptplugin PRIVATE openmpt)
