# This makefile creates XSH::Parser.pm module
#

Parser.pm: Grammar.pm
	perl -MGrammar -e XSH::Grammar::compile

clean:
	rm -f Parser.pm