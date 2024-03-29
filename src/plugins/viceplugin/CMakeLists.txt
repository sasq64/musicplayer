cmake_minimum_required(VERSION 3.12)
project(cpp-mods.musicplayer.viceplugin)

set(SOURCE_FILES
    VicePlugin.cpp
    common/archdep.c
    common/console.c
    common/joy.c
    common/signals.c
    common/vsyncarch.c
    common/gui/uicmdline.c
    common/gui/vsidui.c
    common/null/fullscreen.c
    common/null/ui.c
    common/null/uiapi.c
    common/null/keyboard.c
    vice/alarm.c
    vice/clkguard.c
    vice/charset.c
    vice/cmdline.c
    vice/crc32.c
    vice/debug.c
    vice/datasette.c
    vice/dma.c
    vice/event.c
    vice/findpath.c
    vice/fliplist.c
    vice/init.c
    vice/initcmdline.c
    vice/interrupt.c
    vice/ioutil.c
    vice/kbdbuf.c
    vice/keyboard.c
    vice/joystick.c
    vice/lib.c
    vice/lightpen.c
    vice/log.c
    vice/machine.c
    vice/machine-bus.c
    vice/network.c
    vice/palette.c
    vice/ram.c
    vice/romset.c
    vice/resources.c
    vice/screenshot.c
    vice/snapshot.c
    vice/sound.c
    vice/sysfile.c
    vice/translate.c
    vice/traps.c
    vice/util.c
    vice/vsync.c
    vice/zfile.c
    vice/zipcode.c
    vice/c64/c64-cmdline-options.c
    #vice/c64/c64embedded.c
    vice/c64/c64export.c
    vice/c64/c64gluelogic.c
    vice/c64/c64io.c
    vice/c64/c64keyboard.c
    vice/c64/c64meminit.c
    vice/c64/c64memlimit.c
    vice/c64/c64memrom.c
    vice/c64/c64memsnapshot.c
    vice/c64/c64model.c
    vice/c64/c64pla.c
    vice/c64/c64rom.c
    vice/c64/c64romset.c
    vice/c64/c64sound.c
    vice/c64/c64video.c
    vice/c64/patchrom.c
    vice/c64/psid.c
    vice/c64/reloc65.c
    vice/c64/vsid.c
    vice/c64/vsid-resources.c
    vice/c64/vsid-snapshot.c
    vice/c64/vsidcia1.c
    vice/c64/vsidcia2.c
    vice/c64/vsidmem.c
    vice/c64/vsidstubs.c
    vice/core/ciacore.c
    vice/core/ciatimer.c
    vice/core/viacore.c
    vice/raster/raster.c
    vice/raster/raster-cache.c
    vice/raster/raster-canvas.c
    vice/raster/raster-changes.c
    vice/raster/raster-cmdline-options.c
    vice/raster/raster-line.c
    vice/raster/raster-line-changes.c
    vice/raster/raster-line-changes-sprite.c
    vice/raster/raster-modes.c
    vice/raster/raster-resources.c
    vice/raster/raster-sprite.c
    vice/raster/raster-sprite-cache.c
    vice/raster/raster-sprite-status.c
    vice/sid/fastsid.c
    vice/sid/sid.c
    vice/sid/sid-cmdline-options.c
    vice/sid/sid-resources.c
    vice/sid/sid-snapshot.c
    vice/sid/resid.cpp
    vice/sounddrv/soundaiff.c
    vice/sounddrv/sounddump.c
    vice/sounddrv/soundfs.c
    vice/sounddrv/soundiff.c
    vice/sounddrv/soundmovie.c
    vice/sounddrv/soundvoc.c
    vice/sounddrv/soundwav.c
    vice/vicii/vicii.c
    vice/vicii/vicii-badline.c
    vice/vicii/vicii-color.c
    vice/vicii/vicii-cmdline-options.c
    vice/vicii/vicii-fetch.c
    vice/vicii/vicii-irq.c
    vice/vicii/vicii-mem.c
    vice/vicii/vicii-phi1.c
    vice/vicii/vicii-resources.c
    vice/vicii/vicii-snapshot.c
    vice/vicii/vicii-sprites.c
    vice/vicii/vicii-stubs.c
    vice/vicii/vicii-timing.c
    overrides/attach.c
    overrides/autostart.c
    overrides/maincpu.c
    overrides/mouse.c
    overrides/monitor/monitor.c
    overrides/monitor/monitor_network.c
    overrides/serial.c
    overrides/sounddrv/sounddummy.c
    overrides/vicii/vicii-draw.c
    overrides/video/video.c
    vice/resid/dac.cpp
    vice/resid/envelope.cpp
    vice/resid/extfilt.cpp
    vice/resid/filter.cpp
    vice/resid/pot.cpp
    vice/resid/sid.cpp
    vice/resid/version.cpp
    vice/resid/voice.cpp
    vice/resid/wave.cpp
)

#find_package(ZLIB REQUIRED)

if(NOT TARGET apone::coreutils)
    add_subdirectory(${APONE}/coreutils coreutils)
endif()

if(NOT TARGET apone::crypto)
    add_subdirectory(${APONE}/crypto crypto)
endif()

if(NOT TARGET fmt::fmt)
    add_subdirectory(../../external/fmt)
endif()

if(NOT TARGET ZLIB::ZLIB)
    find_package(ZLIB)
endif()



add_library(viceplayer ${SOURCE_FILES})
target_link_libraries(viceplayer PRIVATE apone::coreutils apone::crypto ZLIB::ZLIB)
include_directories(viceplayer PRIVATE
    .
    common
    common/readline
    vice
    vice/c64
    vice/c64/cart
    vice/c64dtv
    vice/drive
    vice/imagecontents
    vice/lib/p64
    vice/monitor
    vice/raster
    vice/sid
    vice/tape
    vice/userport
    vice/vdrive
    vice/vicii
    vice/rtc
)

add_library(viceplugin OBJECT viceplugin_register.cpp)
target_link_libraries(viceplugin PRIVATE viceplayer)

