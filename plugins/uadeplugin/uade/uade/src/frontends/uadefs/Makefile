BINDIR = /usr/bin
MANDIR = /usr/share/man/man1
UADE123NAME=uade123

CC = gcc
CFLAGS = -Wall -O2 -pthread -I../../include -I../common -I../include `pkg-config fuse --cflags` -DUADENAME=\"/usr/bin/uade123\" -g 
CLIBS =  -L/usr/local/lib -Wl,-rpath,/usr/local/lib `pkg-config fuse --libs` -lm

all:	uadefs

MODULES = uadefs.o ../common/libuade.a

%.o:	%.c
	$(CC) $(CFLAGS) -c $<

uadefs:	$(MODULES)
	$(CC) $(CFLAGS) -o $@ $(MODULES) $(CLIBS)

uadefs.o:	uadefs.c

install:	uadefs
	mkdir -p -m 755 "$(BINDIR)" "$(MANDIR)"
	install uadefs "$(BINDIR)"/
	install -m 644 uadefs.1 "$(MANDIR)"/

clean:	
	rm -f uadefs *.o
