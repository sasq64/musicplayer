
all : build build/Makefile
	make -j8 -C build

install:
	cp build/msxp /usr/local/bin
	rm -rf /usr/local/share/musix
	cp -a data /usr/local/share/musix

build :
	mkdir -p build

build/Makefile :
	(cd build ; cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -G"Unix Makefiles" ..)

