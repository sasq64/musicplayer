Musicplayer
===========

A portable C++ music playing 'framework'
Used by chipmachine

### Quickstart

```
make
build/testing
build/play music/Warhawk.sap
```
Rust stub code (does not play, just calls library)
```
rustc -Lbuild musicplay.rs
LD_LIBRARY_PATH=build ./musicplay
```

### Using

Check out [main.cpp](main.cpp) for the basic concepts; it is very short.
