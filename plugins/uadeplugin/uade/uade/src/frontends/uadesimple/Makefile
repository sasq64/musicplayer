CC = gcc
CFLAGS = -Wall -O2 -I../include -I/usr/include -g 
CLIBS = -L/usr/local/Cellar/libao/1.2.0/lib -lao   -L/usr/local/lib -Wl,-rpath,/usr/local/lib -lm -lbencodetools

all:	uadesimple

MODULES = uadesimple.o audio.o ../common/libuade.a

uadesimple:	$(MODULES)
	$(CC) -o $@ $(MODULES) $(CLIBS)

clean:	
	rm -f uadesimple *.o

%.o:	%.c
	$(CC) $(CFLAGS) -c $<

audio.o:	audio.c audio.h
uadesimple.o:	uadesimple.c
