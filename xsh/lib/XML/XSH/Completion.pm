# $Id: Completion.pm,v 1.7 2003-03-12 13:57:15 pajas Exp $

package XML::XSH::Completion;

use XML::XSH::CompletionList;
use XML::XSH::Functions qw();
use strict;

sub cpl {
  my($word,$line,$pos) = @_;
  if ($line=~/\$([a-zA-Z0-9_]*)$/) {
    return grep { index($_,$1)==0 } XML::XSH::Functions::string_vars;
  } elsif ($line=~/\%([a-zA-Z0-9_]*)$/) {
    return map {'%'.$_} grep { index($_,$1)==0 } XML::XSH::Functions::nodelist_vars;
  } elsif (substr($line,0,$pos)=~/^\s*[^=\s]*$/) {
    return grep { index($_,$word)==0 } @XML::XSH::CompletionList::XSH_COMMANDS;
  } elsif ($line=~/^\s*call\s+(\S*)$|[;}]\s*call\s+(\S*)$/) {
    return grep { index($_,$1)==0 } XML::XSH::Functions::defs;
  } elsif ($line=~/^\s*help\s+(\S*)$|[;}]\s*help\s+(\S*)$/) {
    return grep { index($_,$1)==0 } keys %XML::XSH::Help::HELP;
  } else {
    return eval { map { s:\@$::; $_ } readline::rl_filename_list($_[0]); };
  }
}

sub gnu_cpl {
    my($text, $line, $start, $end) = @_;
    my(@perlret);
    if ($line=~/\$([a-zA-Z0-9_]*)$/) {
      @perlret = grep { index($_,$1)==0 } XML::XSH::Functions::string_vars;
    } elsif ($line=~/\%([a-zA-Z0-9_]*)$/) {
      @perlret = map {'%'.$_} grep { index($_,$1)==0 } XML::XSH::Functions::nodelist_vars;
    } elsif (substr($line,0,$end)=~/^\s*[^=\s]*$/) {
      @perlret = grep { index($_,$text)==0 } @XML::XSH::CompletionList::XSH_COMMANDS;
    } elsif ($line=~/^\s*call\s+(\S*)$|[;}]\s*call\s+(\S*)$/) {
      @perlret = grep { index($_,$1)==0 } XML::XSH::Functions::defs;
    } elsif ($line=~/^\s*help\s+(\S*)$|[;}]\s*help\s+(\S*)$/) {
      @perlret = grep { index($_,$1)==0 } keys %XML::XSH::Help::HELP;
    } else {
      eval {
	@perlret = map { s:\@$::; $_ } Term::ReadLine::GNU::XS::rl_filename_list($_[0]);
      };
    }

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

