cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.openmptplugin)

file(GLOB SOUNDLIB_FILES CONFIGURE_DEPENDS soundlib/*.cpp )
file(GLOB MPT_FILES CONFIGURE_DEPENDS common/mpt*.cpp)

set(SOURCE_FILES
    OpenMPTPlugin.cpp
    ${MPT_FILES}
    common/Logging.cpp
    common/misc_util.cpp
    common/serialization_utils.cpp
    common/typedefs.cpp
    common/version.cpp
    common/ComponentManager.cpp
    libopenmpt/libopenmpt_c.cpp
    libopenmpt/libopenmpt_cxx.cpp
    libopenmpt/libopenmpt_impl.cpp
    libopenmpt/libopenmpt_ext.cpp
    ${SOUNDLIB_FILES}
)

find_package(ZLIB)

add_library(openmptplugin ${SOURCE_FILES})
target_link_libraries(openmptplugin PRIVATE coreutils ${ZLIB_LIBRARIES})
target_include_directories(openmptplugin PRIVATE ${ZLIB_INCLUDE_DIRS} common common/svn_version_default .)
target_compile_definitions(openmptplugin PRIVATE -DLIBOPENMPT_BUILD -DOPENMPT_VERSION_REVISION=1 -DMPT_CHARSET_CUSTOMUTF8 -DMPT_WITH_ZLIB -DNO_PLUGINS)
