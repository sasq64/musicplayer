// Registers every plugin that was built into this library.
//
// The list is not written out here: it comes from `plugin_list.h`, which CMake
// generates from MUSICPLAYER_PLUGINS. Naming a plugin that CMake did not build
// would leave `<plugin>_register` undefined, which a shared library happily
// links anyway and only fails once something links it statically.

#define X(p) extern "C" void p##_register();
#include "plugin_list.h"
#undef X

void register_plugins()
{
#define X(p) p##_register();
#include "plugin_list.h"
#undef X
}
