bin_PROGRAMS = tfmx-play


# set the include path found by configure
INCLUDES = $(SSL_INCLUDES) $(all_includes)

# the library search path.
tfmx_play_LDFLAGS = $(all_libraries) $(SSL_LDFLAGS)
tfmx_play_LDADD = $(LIBSSL) $(LIBSDL_LIBS)
tfmx_play_SOURCES =  audio.c player.c tfmxplay.c
noinst_HEADERS =  player.h tfmxplay.h tfmxsong.h
AM_CFLAGS = $(LIBSDL_CFLAGS)
