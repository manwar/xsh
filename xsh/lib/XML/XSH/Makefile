# This makefile creates XSH::Parser.pm module
#

include ../../config.mk

MODULES=Functions.pm Grammar.pm Help.pm Parser.pm

Parser.pm: Grammar.pm
	perl -MGrammar -e XML::XSH::Grammar::compile

clean:
	rm -f Parser.pm

install:
	$(INSTALL) $(MODULES) $(PREFIX)/lib/XSH`
