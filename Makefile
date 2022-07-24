
all : builds/debug builds/debug/Makefile
	make -j8 -C builds/debug

builds/debug :
	mkdir -p builds/debug

builds/debug/Makefile :
	(cd builds/debug ; cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -G"Unix Makefiles" ../..)

