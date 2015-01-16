AR = ar
CC = gcc
CFLAGS = -Wall -O2 -I../include -I../common -g  -I/usr/local/include
CLIBS =  -L/usr/local/lib -Wl,-rpath,/usr/local/lib -lm -lbencodetools

all:	libuade.a

%.o:	%.c
	$(CC) $(CFLAGS) -c $<

include ../common/Makefile.common

libuade.a: $(COMMONMODULES)
	$(AR) rcs $@ $(COMMONMODULES)

clean:	
	rm -f *.o *.a
