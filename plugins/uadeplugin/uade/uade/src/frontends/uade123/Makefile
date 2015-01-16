BINDIR = /usr/bin
UADE123NAME = uade123

CC = gcc
CFLAGS = -Wall -O2 -I../include -I../common -I/usr/local/Cellar/libao/1.2.0/include  -g  -I/usr/local/include
CLIBS = -L/usr/local/Cellar/libao/1.2.0/lib -lao   -L/usr/local/lib -Wl,-rpath,/usr/local/lib -lm -lbencodetools

all:	uade123

%.o:	%.c
	$(CC) $(CFLAGS) -c $<

MODULES = uade123.o chrarray.o playlist.o playloop.o audio.o terminal.o ../common/libuade.a

uade123:	$(MODULES)
	$(CC) $(CFLAGS) -o $@ $(MODULES) $(CLIBS)

clean:	
	rm -f uade123 *.o

install:	uade123
	mkdir -p "$(BINDIR)"
	rm -f "$(BINDIR)/$(UADE123NAME)"
	cp -f "$(UADE123NAME)" "$(BINDIR)/" || true
	chmod og+rx "$(BINDIR)/$(UADE123NAME)"
	install ../mod2ogg/mod2ogg2.sh "$(BINDIR)/"

uninstall:	
	rm -f "$(BINDIR)/$(UADE123NAME)"

audio.o:	audio.c audio.h
chrarray.o:	chrarray.c chrarray.h
playlist.o:	playlist.c playlist.h uade123.h
playloop.o:	playloop.c playloop.h uade123.h ../include/uade/uadecontrol.h $(PLAYERHEADERS)
terminal.o:	terminal.c terminal.h
uade123.o:	uade123.c uade123.h ../include/uade/amigafilter.h ../include/uade/amifilemagic.h ../include/uade/uadecontrol.h $(PLAYERHEADERS)
