#!/usr/bin/perl
# -*- cperl -*-
use FindBin;
use lib ("$FindBin::RealBin", "$FindBin::RealBin/../lib",
         "$FindBin::Bin","$FindBin::Bin/../lib");

package main;

use strict;

use Getopt::Std;
use vars qw/$opt_q $opt_i $opt_h $opt_V $opt_E $opt_e $opt_d $opt_c/;
use vars qw/$VERSION $REVISION/;

use IO::Handle;
use Parse::RecDescent;

use XSH::Functions qw(&xsh_set_output &xsh &xsh_init
                      &set_opt_q &set_opt_d &set_opt_c);

require Term::ReadLine if $opt_i;

BEGIN {
  getopts('cqdhViE:e:');
  $VERSION='0.7';
  $REVISION='$Revision: 1.12 $';
  $ENV{PERL_READLINE_NOWARN}=1;
}

if ($opt_h) {
  print "Usage: $0 [-q] [-e output-encoding] [-E query-encoding] <commands>\n";
  print "or $0 -h $0 -V\n\n";
  print "   -e   output encoding (default is the document encoding)\n";
  print "   -E   query encoding (default is the output encoding)\n\n";
  print "   -q   quiet\n\n";
  print "   -i   interactive\n\n";
  print "   -d   print debug messages\n\n";
  print "   -c   compile (parse) only and report errors\n\n";
  print "   -V   print version\n\n";
  print "   -h   help\n\n";
  exit 1;
}

if ($opt_V) {
  print "Current version is $VERSION ($REVISION)\n";
}

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

unless (eval { require XSH::Parser; } ) {
  printflush STDERR "Plase wait, parsing grammar...";

  require XSH::Grammar;
  use Cwd 'getcwd';
  my $dir=getcwd();
  chdir $FindBin::RealBin;
  mkdir "XSH";
  chdir "XSH";
  XSH::Grammar::compile();
  chdir $dir;
  print STDERR "done.\n";
}


xsh_init();
XSH::Functions::create_doc("scratch","scratch");
XSH::Functions::set_last_id("scratch");
set_opt_q($opt_q);
set_opt_d($opt_d);
set_opt_c($opt_c);

my $string=join " ",@ARGV;
my $l;

if ($opt_i) {
  $SIG{INT}=sub {  print STDERR "\nCtrl-C pressed. Type exit to quit.\n"; };
  my $rev=$REVISION;
  $rev=~s/\s*\$//g;
  $rev=" xsh - XML Editing Shell version $VERSION ($rev)\n";
  print STDERR "-"x length($rev),"\n";
  print STDERR $rev;
  print STDERR "-"x length($rev),"\n\n";
  print STDERR "Copyright (c) 2002 Petr Pajas.\n";
  print STDERR "This is free software, you may use it and distribute it under\n";
  print STDERR "either the GNU GPL Version 2, or under the Perl Artistic License.\n";
}

if ($string) {
  print "xsh> $string\n";
  xsh($string);
  print "\n";
}

if ($opt_i) {
  my $term;
  $term = new Term::ReadLine 'xsh';
  xsh_set_output($term->OUT) if ($term->OUT);
  print STDERR "Using terminal type: ",$term->ReadLine,"\n" unless "$opt_q";
  print STDERR "Hint: Type `help' or `help | less' to get more help.\n";
  while (defined ($l = $term->readline('xsh> '))) {
    while ($l=~/\\+\s*$/) {
      $l=~s/\\+\s*$//;
      $l .= $term->readline('> ');
    }
    if ($l=~/\S/) {
      xsh($l);
      $term->addhistory($l);
    }
  }
} elsif ($string eq "") {
  xsh(join "",<STDIN>);
}

print STDERR "Good bye!\n" if $opt_i and not "$opt_q";

