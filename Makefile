
all : build build/Makefile
	make -j4 -C build

build :
	mkdir build

build/Makefile :
	(cd build ; cmake ..)

