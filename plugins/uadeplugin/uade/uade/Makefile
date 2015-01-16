# Top-level Makefile for UADE

MAKE = /usr/bin/make

BINDIR = /usr/bin
DATADIR = /usr/share/uade
DOCDIR = {DOCDIR}
MANDIR = /usr/share/man/man1

UADECORENAME=uadecore
UADE123NAME=uade123

COMPILE_RULES = uadesimple libuade uadecore uade123
INSTALL_RULES =  libuadeinstall uadecoreinstall uade123install

all:	src/frontends/include/uade/options.h $(COMPILE_RULES)

staticlibuade:	
	$(MAKE) -C src/frontends/common

libuade:	
	$(MAKE) -C src/frontends/libuade

libuadeinstall:	
	$(MAKE) -C src/frontends/libuade install

uadecore:	
	$(MAKE) -C src

uadecoreinstall:	
	mkdir -p "$(DATADIR)"
	test -e "$(DATADIR)/uade.conf" || cp -f uade.conf "$(DATADIR)/"
	cp -f amigasrc/score/score uaerc eagleplayer.conf "$(DATADIR)/"
	cp -rf players "$(DATADIR)/" || true
	chmod -R og+rX "$(DATADIR)"

	mkdir -p "$(MANDIR)"
	cp doc/uade123.1 "$(MANDIR)"/
	chmod og+r "$(MANDIR)"/uade123.1

	$(MAKE) -C src install

uade123:	staticlibuade
	$(MAKE) -C src/frontends/uade123

uade123install:	uade123
	$(MAKE) -C src/frontends/uade123 install

uadefs:	staticlibuade
	$(MAKE) -C src/frontends/uadefs

uadefsinstall:	uadefs
	$(MAKE) -C src/frontends/uadefs install

uadesimple:	staticlibuade
	$(MAKE) -C src/frontends/uadesimple

src/frontends/include/uade/options.h:	
	@echo ""
	@echo "Run ./configure first!"
	@echo ""
	@false

soundcheck:	
	@ echo ""
	@ echo "### UADE should be playing now 'AHX.Cruisin'"
	@ echo ""
	src/frontends/uade123/$(UADE123NAME) --basedir=. -S amigasrc/score/score -P players/AbyssHighestExperience songs/AHX.Cruisin -u src/uadecore

install:	$(INSTALL_RULES)
	@echo

feclean:	
	$(MAKE) -C src/frontends/common clean
	$(MAKE) -C src/frontends/libuade clean
	$(MAKE) -C src/frontends/uade123 clean
	$(MAKE) -C src/frontends/uadefs clean
	$(MAKE) -C src/frontends/uadesimple clean

clean:	
	$(MAKE) -C src clean
	$(MAKE) feclean
