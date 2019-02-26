
all : build build/Makefile
	make -j8 -C build

build :
	mkdir build

build/Makefile :
	(cd build ; cmake -G"Unix Makefiles" ..)

