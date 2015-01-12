cmake_minimum_required(VERSION 2.8.4)
project(libmpg123)

enable_language(ASM)
	# lfs_wrap.c
	# dct36_3dnowext.S
	# dct36_3dnow.S
	# dct36_sse.S
	# dct36_neon.S
	# dct36_neon64.S
	# dct64_3dnowext.S
	# dct64_3dnow.S
	# dct64_altivec.c
	# dct64_i386.c
	# dct64_i486.c
	# dct64_mmx.S
	# dct64_sse.S
	# dct64_sse_float.S
	# dct64_neon.S
	# dct64_neon_float.S
	# dct64_neon64.S
	# dct64_neon64_float.S
	# synth_3dnowext.S
	# synth_3dnow.S
	# synth_altivec.c
	# synth_i486.c
	# synth_i586_dither.S
	# synth_i586.S
	# synth_mmx.S
	# synth_sse.S
	# synth_sse_float.S
	# synth_sse_s32.S
	# synth_sse_accurate.S
	# synth_stereo_sse_float.S
	# synth_stereo_sse_s32.S
	# synth_stereo_sse_accurate.S
	# synth_x86_64_accurate.S
	# synth_stereo_x86_64_accurate.S
	# synth_arm_accurate.S
	# synth_neon.S
	# synth_neon_float.S
	# synth_neon_s32.S
	# synth_neon_accurate.S
	# synth_stereo_neon.S
	# synth_stereo_neon_float.S
	# synth_stereo_neon_s32.S
	# synth_stereo_neon_accurate.S
	# synth_neon64.S
	# synth_neon64_float.S
	# synth_neon64_s32.S
	# synth_neon64_accurate.S
	# synth_stereo_neon64.S
	# synth_stereo_neon64_float.S
	# synth_stereo_neon64_s32.S
	# synth_stereo_neon64_accurate.S
	# synth_stereo_avx_accurate.S
	# equalizer_3dnow.S
	# tabinit_mmx.S
	# getcpuflags.S

set(SOURCE_FILES
	compat.c
	parse.c
	frame.c
	format.c
	dct64.c
	equalizer.c
	id3.c
	optimize.c
	readers.c
	tabinit.c
	libmpg123.c
	index.c
	lfs_alias.c
	icy.c
	icy2utf8.c
	layer1.c
	layer2.c
	layer3.c
	dither.c
	feature.c
	ntom.c
	synth.c
	synth_8bit.c
	synth_real.c
	synth_s32.c
	stringbuf.c
)

if(RASPBERRY)
	set(SOURCE_FILES ${SOURCE_FILES}
	  synth_arm.S
	  getcpuflags_arm.c
	  check_neon.S
	)
	add_definitions(-DOPT_ARM -DREAL_IS_FLOAT -DNOXFERMEM)
else()
	set(SOURCE_FILES ${SOURCE_FILES}
		dct36_x86_64.S
		dct36_avx.S
		dct64_x86_64.S
		dct64_x86_64_float.S
		dct64_avx.S
		dct64_avx_float.S
		synth_x86_64.S
		synth_x86_64_float.S
		synth_x86_64_s32.S
		synth_stereo_x86_64.S
		synth_stereo_x86_64_float.S
		synth_stereo_x86_64_s32.S
		synth_stereo_avx.S
		synth_stereo_avx_float.S
		synth_stereo_avx_s32.S
		getcpuflags_x86_64.S
	)
	add_definitions(-DOPT_MULTI -DOPT_X86_64 -DOPT_GENERIC -DOPT_GENERIC_DITHER -DREAL_IS_FLOAT -DOPT_AVX -DNOXFERMEM)
endif()


set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-format")


include_directories(../.. ..)

add_library(libmpg123 ${SOURCE_FILES})
