# This makefile creates XSH::Parser.pm module
#

include config.mk

all: subdirs

subdirs:
	$(MAKE) -C XSH

clean:
	$(MAKE) -C XSH clean

install:
	$(INSTALL) -m 775 xsh.pl $(PREFIX)/bin
	mkdir -p $(PREFIX)/lib/XSH
	$(MAKE) -C XSH install
