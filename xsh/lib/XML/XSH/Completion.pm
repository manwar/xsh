# $Id: Completion.pm,v 1.15 2003-06-05 10:41:07 pajas Exp $

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
  } elsif ($line=~/^\s*x?(?:insert|add)\s+(\S*)$|[;}]\s*x?(?:insert|add)\s+(\S*)$/) {
    return grep { index($_,$1)==0 } qw(element attribute attributes text
                                       cdata pi comment chunk entity_reference);
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
    return xpath_complete($line,$word,$pos);
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
    } elsif ($line=~/^\s*x?(?:insert|add)\s+(\S*)$|[;}]\s*x?(?:insert|add)\s+(\S*)$/) {
      @perlret = grep { index($_,$1)==0 } qw(element attribute attributes text
					     cdata pi comment chunk entity_reference);
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
      @perlret = xpath_complete($line,substr($line,$start,$end),$start);
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

sub xpath_complete_str {
  my $str = reverse($_[0]);
  my $debug = $_[1];
  my $result="";
  my $NAMECHAR = '[-_.[:alnum:]]';
  my $NNAMECHAR = '[-:_.[:alnum:]]';
  my $NAME = "${NAMECHAR}*${NNAMECHAR}*[_.[:alpha:]]";

  my $WILDCARD = '\*(?!\*|${NAME}|\)|\]|\.)';
  my $OPER = qr/(?:[,=<>\+\|]|-(?!${NAME})|(?:vid|dom|dna|ro)(?=\s*\]|\s*\)|\s*[0-9]+(?!${NNAMECHAR})|\s+{$NAMECHAR}|\s+\*))/;

  print "'$str'\n" if $debug;
  my $localmatch;

 STEP0:
  if ($str =~ /\G\s*[\]\)]/gsco) {
    print "No completions after ] or )\n" if $debug;
    return;
  }

 STEP1:
  if ( $str =~ /\G(${NAMECHAR}+)?(?::(${NAMECHAR}+))?/gsco ) {
    if ($2 ne "") {
      $localmatch=reverse($2).":".reverse($1);
      if ($1 ne "") {
	$result=reverse($2).':*[starts-with(local-name(),"'.reverse($1).'")]'.$result;
      } else {
	$result=reverse($2).':*'.$result;
      }
    } else {
      $localmatch=reverse($1);
      $result='*[starts-with(name(),"'.$localmatch.'")]'.$result;
    }
  } else {
    $result='*'.$result;
  }
  if ($str =~ /\G\@/gsco) {
    $result="@".$result;
  }

 STEP2:
  print "STEP2-LOCALMATCH: $localmatch\n" if $debug;
  print "STEP2: $result\n" if $debug;
  print "STEP2-STR: ".reverse(substr($str,pos($str)))."\n" if $debug;
  while ($str =~ m/\G(::|:|\@|${NAME}\$?|\/\/|\/|${WILDCARD}|\)|\])/gsco) {
    print "STEP2-MATCH: '$1'\n" if $debug;
    if ($1 eq ')' or $1 eq ']') {
      # eat ballanced upto $1
      my @ballance=(($1 eq ')' ? '(' : '['));
      $result=$1.$result;
      print "STEP2: Ballanced $1\n" if $debug;
      do {
	$result=reverse($1).$result if $str =~ m/\G([^]["'()]+)/gsco; # skip normal characters
	return ($result,$localmatch) unless $str =~ m/\G(.)/gsco;
	if ($1 eq $ballance[$#ballance]) {
	  pop @ballance;
	} elsif ($1 eq ')') {
	  push @ballance, '(';
	} elsif ($1 eq ']') {
	  push @ballance, '[';
	} elsif ($1 eq '"') {
	  push @ballance, '"';
	} elsif ($1 eq "'") {
	  push @ballance, "'";
	} else {
	  print STDERR "Error 2: lost in an expression on '$1' ";
	  print STDERR reverse(substr($str,pos()))."\n";
	  print "-> $result\n";
	  return undef;
	}
	$result=$1.$result;
      }	while (@ballance);
    } else {
      $result=reverse($1).$result;
    }
  }

 STEP3:
  print "STEP3: $result\n" if $debug;
  print "STEP3-STR: ".reverse(substr($str,pos($str)))."\n" if $debug;
  if (substr($result,0,1) eq '/') {
    if ($str =~ /\G['"]/gsco) {
      print STDERR "Error 1: unballanced '$1'\n";
      return undef;
    } elsif ($str =~ /\G(?:\s+['"]|\(|\[|${OPER})/gsco) {
      return ($result,$localmatch);
    }
    return ($result,$localmatch); # uncertain!!!
  } else {
    return ($result,$localmatch) if ($str=~/\G\s+(?=${OPER})/gsco);
  }

 STEP4:
  print "STEP4: $result\n" if $debug;
  print "STEP4-STR: ".reverse(substr($str,pos($str)))."\n" if $debug;
  my @ballance;
  do {
    $str =~ m/\G([^]["'()]+)/gsco; # skip normal characters
    print "STEP4-MATCH '".reverse($1)."'\n" if $debug;
    return ($result,$localmatch) unless $str =~ m/\G(.)/gsco;
    print "STEP4-BALLANCED '$1'\n" if $debug;
    if (@ballance and $1 eq $ballance[$#ballance]) {
      pop @ballance;
    } elsif ($1 eq ')') {
      push @ballance, '(';
    } elsif ($1 eq ']') {
      push @ballance, '[';
    } elsif ($1 eq '"') {
      push @ballance, '"';
    } elsif ($1 eq "'") {
      push @ballance, "'";
    } elsif (not(@ballance) and $1 eq '[') {
      print "STEP4-PRED2STEP '$1'\n" if $debug;
      $result='/'.$result;
      goto STEP2;
    }
  } while (@ballance);
  goto STEP4;
}

sub xpath_complete {
  my ($line, $word,$pos)=@_;
  return () unless $XML::XSH::Functions::XPATH_COMPLETION;
  my $str=XML::XSH::Functions::toUTF8($XML::XSH::Functions::QUERY_ENCODING,
				      substr($line,0,$pos).$word);
  my ($xp,$local) = xpath_complete_str($str,0);
#  XML::XSH::Functions::__debug("COMPLETING $_[0] local $local as $xp\n");
  return () if $xp eq "";
  my ($docid,$q) = ($xp=~/^(?:([a-zA-Z_][a-zA-Z0-9_]*):(?!:))?((?:.|\n)*)$/);
  if ($docid ne "" and not XML::XSH::Functions::_doc($docid)) {
    $q=$docid.":".$q;
    $docid="";
  }
  my ($id,$query,$doc)=XML::XSH::Functions::_xpath([$docid,$q]);
  return () unless (ref($doc));
  my $ql= eval { XML::XSH::Functions::find_nodes([$id,$query]) };
  return () if $@;
  my %names;
  @names{ map { 
    XML::XSH::Functions::fromUTF8($XML::XSH::Functions::QUERY_ENCODING,
				  substr(substr($str,0,
						length($str)
						-length($local)).
					 $_->nodeName(),$pos))
  } @$ql}=();

  my @completions = sort { $a cmp $b } keys %names;
#  print "completions so far: @completions\n";

  if (($XML::XSH::Functions::XPATH_AXIS_COMPLETION eq 'always' or
       $XML::XSH::Functions::XPATH_AXIS_COMPLETION eq 'when-empty' and !@completions)
      and $str =~ /[ \n\t\r|([=<>+-\/]([[:alpha:]][-:[:alnum:]]*)?$/ and $1 !~ /::/) {
    # complete XML axis
    my ($pre,$axpart)=($word =~ /^(.*[^[:alnum:]])?([[:alpha:]][-[:alnum:]:]*)/);
#    print "\nWORD: $word\nPRE: $pre\nPART: $axpart\nSTR:$str\n";
    foreach my $axis (qw(following preceding following-or-self preceding-or-self
			 parent ancestor ancestor-or-self descendant self
			 descendant-or-self child attribute namespace)) {
      if ($axis =~ /^${axpart}/) {
	push @completions, "${pre}${axis}::";
      }
    }
  }
  return @completions;
}

1;

