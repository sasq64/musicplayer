


#define PLUGIN(x) \
extern "C" void x ## _register(); \

#define PLUGIN2(x) \
    x ## _register(); \


PLUGIN(adplugin)
PLUGIN(aoplugin)
PLUGIN(ayflyplugin)
PLUGIN(gmeplugin)
PLUGIN(gsfplugin)
PLUGIN(heplugin)
PLUGIN(hivelyplugin)
PLUGIN(htplugin)
PLUGIN(mdxplugin)
PLUGIN(ndsplugin)
PLUGIN(openmptplugin)
PLUGIN(sc68plugin)
PLUGIN(stsoundplugin)
PLUGIN(tedplugin)
PLUGIN(uadeplugin)
PLUGIN(v2plugin)
PLUGIN(usfplugin)
PLUGIN(rsnplugin)
PLUGIN(s98plugin)
PLUGIN(sidplugin)


void register_plugins() {
    PLUGIN2(adplugin)
    PLUGIN2(aoplugin)
    PLUGIN2(ayflyplugin)
    PLUGIN2(gmeplugin)
    PLUGIN2(gsfplugin)
    PLUGIN2(heplugin)
    PLUGIN2(hivelyplugin)
    PLUGIN2(htplugin)
    PLUGIN2(mdxplugin)
    PLUGIN2(ndsplugin)
    PLUGIN2(openmptplugin)
    PLUGIN2(sc68plugin)
    PLUGIN2(stsoundplugin)
    PLUGIN2(tedplugin)
    PLUGIN2(uadeplugin)
    PLUGIN2(v2plugin)
    PLUGIN2(usfplugin)
    PLUGIN2(rsnplugin)
    PLUGIN2(s98plugin)
    PLUGIN2(sidplugin)
}

