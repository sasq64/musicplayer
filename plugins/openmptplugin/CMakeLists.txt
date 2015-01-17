cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.musicplayer.openmptplugin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

set(SOURCE_FILES
	OpenMPTPlugin.cpp
	#common/AudioCriticalSection.cpp
	#common/stdafx.cpp
	common/Logging.cpp
	common/misc_util.cpp
	#common/mptPathString.cpp
	common/mptString.cpp
	#common/Profiler.cpp
	common/serialization_utils.cpp
	common/typedefs.cpp
	common/version.cpp
	libopenmpt/libopenmpt_c.cpp
	libopenmpt/libopenmpt_cxx.cpp
	libopenmpt/libopenmpt_impl.cpp
	libopenmpt/libopenmpt_ext.cpp
	soundlib/Dither.cpp
	#soundlib/Dlsbank.cpp
	soundlib/Fastmix.cpp
	soundlib/ITCompression.cpp
	soundlib/ITTools.cpp
	soundlib/Load_669.cpp
	soundlib/Load_amf.cpp
	soundlib/Load_ams.cpp
	soundlib/Load_dbm.cpp
	soundlib/Load_digi.cpp
	soundlib/Load_dmf.cpp
	soundlib/Load_dsm.cpp
	soundlib/Load_far.cpp
	soundlib/Load_gdm.cpp
	soundlib/Load_imf.cpp
	soundlib/Load_it.cpp
	soundlib/Load_itp.cpp
	soundlib/load_j2b.cpp
	soundlib/Load_mdl.cpp
	soundlib/Load_med.cpp
	soundlib/Load_mid.cpp
	soundlib/Load_mo3.cpp
	soundlib/Load_mod.cpp
	soundlib/Load_mt2.cpp
	soundlib/Load_mtm.cpp
	soundlib/Load_okt.cpp
	soundlib/Load_psm.cpp
	soundlib/Load_ptm.cpp
	soundlib/Load_s3m.cpp
	soundlib/Load_stm.cpp
	soundlib/Load_ult.cpp
	soundlib/Load_umx.cpp
	soundlib/Load_wav.cpp
	soundlib/Load_xm.cpp
	soundlib/Message.cpp
	soundlib/MIDIEvents.cpp
	soundlib/MIDIMacros.cpp
	soundlib/MixerLoops.cpp
	soundlib/MixerSettings.cpp
	soundlib/Mmcmp.cpp
	soundlib/ModChannel.cpp
	soundlib/modcommand.cpp
	soundlib/ModInstrument.cpp
	soundlib/ModSample.cpp
	soundlib/ModSequence.cpp
	soundlib/modsmp_ctrl.cpp
	soundlib/mod_specifications.cpp
	soundlib/patternContainer.cpp
	soundlib/pattern.cpp
	soundlib/RowVisitor.cpp
	soundlib/S3MTools.cpp
	soundlib/SampleFormats.cpp
	soundlib/SampleIO.cpp
	soundlib/Sndfile.cpp
	soundlib/Snd_flt.cpp
	soundlib/Snd_fx.cpp
	soundlib/Sndmix.cpp
	soundlib/SoundFilePlayConfig.cpp
	soundlib/Tables.cpp
	#soundlib/Tagging.cpp
	soundlib/tuningbase.cpp
	soundlib/tuningCollection.cpp
	soundlib/tuning.cpp
	soundlib/WAVTools.cpp
	soundlib/WindowedFIR.cpp
	soundlib/XMTools.cpp
)
include_directories(common common/svn_version_default .)
add_definitions(-DLIBOPENMPT_BUILD -DMPT_CHARSET_CUSTOMUTF8 -DMPT_WITH_ZLIB )

find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})

add_library(openmptplugin ${SOURCE_FILES})
target_link_libraries(openmptplugin ${ZLIB_LIBRARIES})
