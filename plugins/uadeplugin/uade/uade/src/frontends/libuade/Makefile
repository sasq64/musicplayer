LIBDIR = /usr/lib
INCLUDEDIR = /usr/include
PKGCONFIGDIR = /usr/lib/pkgconfig
SHAREDSUFFIX = dylib

AR = ar
CC = gcc
CFLAGS = -Wall -O2 -I../include -I../common -fPIC -shared -dynamic -bundle -undefined suppress -force_flat_namespace -g  -I/usr/local/include
CLIBS =  -L/usr/local/lib -Wl,-rpath,/usr/local/lib -lm -lbencodetools

all:	libuade.$(SHAREDSUFFIX) libuade.a

%.o:	%.c
	$(CC) $(CFLAGS) -c $<

include ../common/Makefile.common

libuade.$(SHAREDSUFFIX):	$(COMMONMODULES)
	$(CC) -install_name $(LIBDIR)/$@ -dynamiclib -o $@ $(CLIBS) $(COMMONMODULES)

libuade.a:	$(COMMONMODULES)
	$(AR) rcs $@ $(COMMONMODULES)

install:	libuade.$(SHAREDSUFFIX)
	mkdir -p "$(INCLUDEDIR)"/uade "$(LIBDIR)" "$(PKGCONFIGDIR)"
	install -m 644 $< "$(LIBDIR)"/
	install -m 644 ../include/uade/options.h ../include/uade/uade.h "$(INCLUDEDIR)"/uade/
	install -m 644 ../../../libuade.pc "$(PKGCONFIGDIR)"/

clean:	
	rm -f *.o *.so *.a
