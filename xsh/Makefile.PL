# $Id: Makefile.PL,v 2.0 2004-12-02 17:26:10 pajas Exp $

use strict;

use ExtUtils::MakeMaker;

$| = 1;

WriteMakefile(
    'NAME'      => 'XML::XSH2',
    'VERSION_FROM' => 'lib/XML/XSH2/Functions.pm',
    'EXE_FILES' => ['xsh'],
    'PREREQ_PM' => {
		    'XML::LibXML' => 1.56,
		    'XML::LibXSLT' => 1.53,
		    'XML::LibXML::Iterator' => 0,
		    'Parse::RecDescent' => 1.94,
		    'XML::XUpdate::LibXML' => "0.4.0",
		    'XML::LibXML::XPathContext' => 0.06,
		   },
     AUTHOR       => 'Petr Pajas (pajas@matfyz.cz)',
     ABSTRACT     => 'XML Editing Shell',
     MAN3PODS     => { 'XSH2.pod' => 'blib/man3/XSH2.3' },
    'dist' => {
         COMPRESS  => 'gzip',
         SUFFIX    => 'gz',
	 CI        => 'cvs ci',
	 RCS_LABEL => 'cvs admin -Nv$(VERSION_SYM):',
    },
);

sub MY::postamble {

return <<'EOF';
cvs:    xml
	rm -f Makefile
	echo "Please, re-run 'perl Makefile.PL' and 'make'"
	echo

xml:
	$(PERL) tools/gen_grammar.pl src/xsh_grammar.xml > lib/XML/XSH2/Grammar.pm
	$(PERL) tools/gen_commands.pl src/xsh_grammar.xml > lib/XML/XSH2/Commands.pm
	$(PERL) tools/gen_help.pl src/xsh_grammar.xml > lib/XML/XSH2/Help.pm
	$(PERL) tools/gen_pod.pl src/xsh_grammar.xml > XSH2.pod
	$(PERL) tools/gen_completions.pl src/xsh_grammar.xml > lib/XML/XSH2/CompletionList.pm
	cd lib/XML/XSH2; env LC_ALL=C LANG=C $(PERL) -MGrammar -e XML::XSH2::Grammar::compile
	$(PERL) -c lib/XML/XSH2/Parser.pm

grammar:
	cd lib/XML/XSH2; env LC_ALL=C LANG=C $(PERL) -MGrammar -e XML::XSH2::Grammar::compile
	$(PERL) -c lib/XML/XSH2/Parser.pm

docs: all
	pod2html --noindex --title "xsh - XML Editing Shell" < xsh > doc/xsh.html
	$(PERL) ./xsh -l tools/gen_reference.xsh
	$(PERL) ./xsh -l tools/gen_doc.xsh

winppd: ppd
	$(PERL) -i~ -pe 's/OS NAME=".*"/OS NAME="MSWin32"/; s/ARCHITECTURE NAME=".*"/ARCHITECTURE NAME="MSWin32-x86-multi-thread"/; s/CODEBASE HREF=".*"/CODEBASE HREF="XML-XSH2.tar.gz"/;' XML-XSH2.ppd

EOF

}

