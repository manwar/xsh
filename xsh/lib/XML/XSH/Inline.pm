# $Id: Inline.pm,v 1.1 2003-11-13 09:19:51 pajas Exp $

package XML::XSH::Inline;

use vars qw($VERSION $terminator);

use strict;
use XML::XSH qw();
$VERSION = '0.1';
$terminator = undef;

use Filter::Simple;

sub filter {
  my $t=defined($terminator) ? $terminator : '__END__';
  s/$terminator\s*$// if defined($terminator);
  $_="XML::XSH::xsh(<<'$t');\n".$_."$t\n";
  $_;
};

FILTER(\&filter);

1;

=head1 NAME

XML::XSH::Inline - Insert XSH commands directly into your Perl scripts

=head1 SYNOPSIS

   # perl code

   use XML::XSH::Inline;

   # XSH Language commands (see L<XSH>)

   no XSH::XSH::Inline;

   # perl code

=head1 REQUIRES

Filter::Simple, XML::XSH

=head1 EXPORTS

None.

=head1 AUTHOR

Petr Pajas, pajas@matfyz.cz

=head1 SEE ALSO

L<xsh>, L<XSH>, L<XML::XSH>

=cut
