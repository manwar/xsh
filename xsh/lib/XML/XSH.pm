# $Id: XSH.pm,v 1.9 2003-03-12 13:54:11 pajas Exp $

package XML::XSH;

use strict;
use vars qw(@EXPORT_OK @EXPORT @ISA $VERSION $xshNS);

use Exporter;
use XML::XSH::Functions qw(:default);
use XML::XSH::Completion;

BEGIN {
  $VERSION   = '1.1';
  @ISA       = qw(Exporter);
  @EXPORT = qw(&xsh);
  @EXPORT_OK = @XML::XSH::Functions::EXPORT_OK;
  $xshNS = 'http://xsh.sourceforge.net/xsh/';
}

1;

=head1 NAME

XML::XSH - A powerfull scripting language/shell for XPath-based editing of XML

=head1 SYNOPSIS

 use XML::XSH;
 xsh(<<'__XSH__');

   # ... XSH Language commands (example borrowed from Kip Hampton's article) ...
   open sources="perl_channels.xml";   # open a document from file
   create merge news-items;            # create a new document

   foreach sources://rss-url {         # traverse the sources document
       open src=${{ string(@href) }};  # load the URL given by @href attribute
       map { $_ = lc($_) } //*;        # lowercase all tag names
       xcopy src://item                # copy all items from the src document
          into merge:/news-items[1];   # into the news-items element in merge document
       close src;                      # close src document (not mandatory)
   };
   close sources;
   saveas merge "files/headlines.xml"; # save the resulting merge document
   close merge;

 __XSH__

=head1 REQUIRES

XML::LibXML, XML::XUpdate::LibXML

=head1 EXPORTS

xsh()

=head1 DESCRIPTION

This module implements XSH sripting language. XSH stands for XML
(editing) SHell. XSH language is documented on
http://xsh.sourceforge.net/doc.

The distribution package of XML::XSH module includes XSH shell
interpreter called C<xsh>. To use it interactively, run C<xsh -i>.

=head2 C<xsh_init>

Initialize the XSH language parser and interpreter.

=head2 C<xsh>

Execute commands in XSH language.

=head2 EXPORT

None.

=head1 AUTHOR

Petr Pajas, pajas@matfyz.cz

=head1 SEE ALSO

L<XML::LibXML>, L<XML::XUpdate>, http://xsh.sourceforge.net/doc

=cut
