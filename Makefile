
all : build build/Makefile
	make -j8 -C build

install:
	sudo ./install.sh

build :
	mkdir -p build

build/Makefile :
	(cd build ; cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -G"Unix Makefiles" ..)

