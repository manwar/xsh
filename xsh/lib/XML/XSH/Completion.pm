# $Id: Completion.pm,v 1.1 2002-03-05 13:50:11 pajas Exp $

package XML::XSH::Completion;

use strict;
use vars qw(@commands);

@commands=qw(
!
add
assign
call
cd
clone
close
complete_attributes
copy
count
cp
create
debug
def
define
defs
delete
dtd
echo
enc
encoding
eval
exec
exit
files
foreach
help
chdir
if
include
insert
keep_blanks
list
load_ext_dtd
ls
move
mv
new
nodebug
on
open
parser_expands_entities
parser_expands_xinclude
pedantic_parser
perl
print
process_xinclude
process_xincludes
query-encoding
quiet
remove
run-mode
save
saveas
sed
select
system
test-mode
transform
unless
valid
validate
validation
variables
verbose
version
while
xadd
xcopy
xcp
xinsert
xmv
xslt
);

sub cpl {
  my($word,$line,$pos) = @_;
  if ($line=~/^\s*\S*$/) {
    return grep { index($_,$word)==0 } @commands;
  } else {
    return readline::rl_filename_list(@_);
  }
}

sub gnu_cpl {
    my($text, $line, $start, $end) = @_;
    my(@perlret) = cpl($text, $line, $start);
    # find longest common match. Can anybody show me how to peruse
    # T::R::Gnu to have this done automatically? Seems expensive.
    return () unless @perlret;
    my($newtext) = $text;
    for (my $i = length($text)+1;;$i++) {
        last unless length($perlret[0]) && length($perlret[0]) >= $i;
        my $try = substr($perlret[0],0,$i);
        my @tries = grep {substr($_,0,$i) eq $try} @perlret;
        # warn "try[$try]tries[@tries]";
        if (@tries == @perlret) {
            $newtext = $try;
        } else {
            last;
        }
    }
    ($newtext,@perlret);
}

1;

