#pragma once

extern "C"
{
    #include "drive.h"
    #include "gfxoutput.h"
    #include "init.h"
    #include "initcmdline.h"
    #include "lib.h"
    #include "machine.h"
    #include "maincpu.h"
    #include "psid.h"
    #include "resources.h"
    #include "sid/sid.h"
    #include "sound.h"
    #include "sysfile.h"

    void psid_play(short* buf, int size);
    const char* psid_get_name();
    const char* psid_get_author();
    const char* psid_get_copyright();
}

