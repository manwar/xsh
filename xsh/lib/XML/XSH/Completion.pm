# $Id: Completion.pm,v 1.9 2003-05-06 17:35:49 pajas Exp $

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
  } elsif (substr($line,0,$pos)=~
	   /(?:^|[;}])\s*save(?:\s+|_|-)(?:(?:html|xml|xinclude|HTML|XML|XInclude|XINCLUDE)(?:\s+|_|-))?(?:(?:file|pipe|string|FILE|PIPE|STRING)\s+)?([a-zA-Z0-9_]*)$/) {
    return grep { index($_,$word)==0 } XML::XSH::Functions::docs;
  } elsif (substr($line,0,$pos)=~
	   /(?:^|[;}])\s*(?:open(?:\s+|_|-)(?:(?:html|xml|docbook|HTML|XML|DOCBOOK)(?:\s+|_|-))?(?:(?:file|pipe|string|FILE|PIPE|STRING)\s+)?)?[a-zA-Z0-9_]+\s*=\s*(\S*)$/
	   ||
	   substr($line,0,$pos)=~
	   /(?:^|[;}])\s*save(?:\s+|_|-)(?:(?:html|xml|xinclude|HTML|XML|XInclude|XINCLUDE)(?:\s+|_|-))?(?:(?:file|pipe|string|FILE|PIPE|STRING)\s+)?[a-zA-Z0-9_]+\s+(\S*)$/
	  ) {
    my @results=eval { map { s:\@$::; $_ } readline::rl_filename_list($_[0]); };
    if (@results==1 and -d $results[0]) {
      $readline::rl_completer_terminator_character='';
    }
    return @results;
  } else { # XPath completion
#    print "\nW:$word\nL:$line\nP:$pos\n";
    $readline::rl_completer_terminator_character='';
    return XML::XSH::Functions::xpath_complete($line,$word,$pos);
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
    } elsif (substr($line,0,$end)=~
	   /(?:^|[;}])\s*save(?:\s+|_|-)(?:(?:html|xml|xinclude|HTML|XML|XInclude|XINCLUDE)(?:\s+|_|-))?(?:(?:file|pipe|string|FILE|PIPE|STRING)\s+)?([a-zA-Z0-9_]*)$/) {
      @perlret = grep { index($_,substr($line,$start,$end))==0 } XML::XSH::Functions::docs;
    } elsif (substr($line,0,$end)=~
	     /(?:^|[;}])\s*(?:open(?:\s+|_|-)(?:(?:html|xml|docbook|HTML|XML|DOCBOOK)(?:\s+|_|-))?(?:(?:file|pipe|string|FILE|PIPE|STRING)\s+)?)?[a-zA-Z0-9_]+\s*=\s*(\S*)$/
	     ||
	     substr($line,0,$end)=~
	     /(?:^|[;}])\s*save(?:\s+|_|-)(?:(?:html|xml|xinclude|HTML|XML|XInclude|XINCLUDE)(?:\s+|_|-))?(?:(?:file|pipe|string|FILE|PIPE|STRING)\s+)?[a-zA-Z0-9_]+\s+(\S*)$/
	    ) {
      @perlret = eval { map { s:\@$::; $_ } Term::ReadLine::GNU::XS::rl_filename_list($_[0]) };
      if (@perlret==1 and -d $perlret[0]) {
	&main::_term()->Attribs->{completion_append_character} = '';
      } else {
	&main::_term()->Attribs->{completion_append_character} = ' ';
      }
    } else { # XPath completion
      &main::_term()->Attribs->{completion_append_character} = '';
      @perlret = XML::XSH::Functions::xpath_complete($line,substr($line,$start,$end),$start);
    }

    # find longest common match. Can anybody show me how to persuade
    # T::R::Gnu to do this automatically? Seems expensive.
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

