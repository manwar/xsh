# $Id: XSH.pm,v 1.1 2002-03-05 13:55:28 pajas Exp $

package XML::XSH;

use strict;
use vars qw(@EXPORT_OK @ISA $VERSION);

use Exporter;
use XML::XSH::Functions qw(:default);
use XML::XSH::Completion;

BEGIN {
  $VERSION   = '0.9';
  @ISA       = qw(Exporter);
  @EXPORT_OK = @XML::XSH::Functions::EXPORT_OK;
}

1;
