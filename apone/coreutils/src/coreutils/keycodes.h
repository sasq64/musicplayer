#pragma once
#include <cstdint>
#ifdef _WIN32
#undef DELETE
#endif

/*
    * Ascii keys (0-9,a-z,`-=[]\;',./) are bound to their ascii value.
    * F1-F12 are sequential
*/




namespace keycodes {

// Format

    enum key {
        // GAMEPAD BUTTONS are mapped in 0x1 - 0x1F range
        BUTTON_LEFT = 1,
        BUTTON_RIGHT,
        BUTTON_UP,
        BUTTON_DOWN,
        BUTTON_A,
        BUTTON_B,
        BUTTON_X,
        BUTTON_Y,
        BUTTON_START,
        BUTTON_SELECT,

        SPACE = 0x20,

        // Non ascii keyboard buttons are 0x80 - 0xEF

        SHIFT_LEFT = 0x80,
        SHIFT_RIGHT,
        ALT_LEFT,
        ALT_RIGHT,
        CTRL_LEFT,
        CTRL_RIGHT,
        WINDOW_LEFT,
        WINDOW_RIGHT,
        UP,
        DOWN,
        LEFT,
        RIGHT,
        ENTER,
        ESCAPE,
        BACKSPACE,
        TAB,
        PAGEUP,
        PAGEDOWN,
        DELETE,
        INSERT,
        HOME,
        END,
        F1,
        F2,
        F3,
        F4,
        F5,
        F6,
        F7,
        F8,
        F9,
        F10,
        F11,
        F12,
        CAPS_LOCK,

        CLICK = 0x300,
        RIGHT_CLICK,
        NO_KEY = 0xffffffff,
    };

constexpr uint32_t KEY_RELEASED = 0x40000000;
constexpr uint32_t KEY_RAW = 0x80000000;

constexpr bool keyUp(uint32_t k) { return (k & KEY_RELEASED) != 0; }
constexpr bool keyDown(uint32_t k) { return (k & KEY_RELEASED) == 0; }

#ifdef GLFW_VERSION_MAJOR

inline uint32_t from_glfw(uint32_t gkey) {
    static int translate[] = {
        ESCAPE, ENTER, TAB,    BACKSPACE, INSERT, DELETE, RIGHT,     LEFT,
        DOWN,   UP,    PAGEUP, PAGEDOWN,  HOME,   END,    CAPS_LOCK, 0,
        0,      0,     0,      F1,        F2,     F3,     F4,        F5,
        F6,     F7,    F8,     F9,        F10,    F11,    F12};
    if(gkey >= 'A' && gkey <= 'Z')
        return gkey + 0x20;
    else if(gkey < 128)
        return gkey;
    else if(gkey >= 256 && gkey < 256 + sizeof(translate)/sizeof(int)) 
        return translate[gkey - 256];
    return 0;
}

#endif


} // namespace keycodes
