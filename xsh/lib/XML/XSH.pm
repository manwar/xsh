# $Id: XSH.pm,v 1.4 2002-08-26 14:36:02 pajas Exp $

package XML::XSH;

use strict;
use vars qw(@EXPORT_OK @ISA $VERSION $xshNS);

use Exporter;
use XML::XSH::Functions qw(:default);
use XML::XSH::Completion;

BEGIN {
  $VERSION   = '1.1';
  @ISA       = qw(Exporter);
  @EXPORT_OK = @XML::XSH::Functions::EXPORT_OK;
  $xshNS = 'http://xsh.sourceforge.net/xsh';
}

1;
