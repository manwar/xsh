#!/usr/bin/perl
# -*- cperl -*-
package main;
use strict;

use Parse::RecDescent;
use XML::LibXML;
use Text::Iconv;

use Getopt::Std;
getopts('qdhViE:e:');
use vars qw/$opt_q $opt_i $opt_h $opt_V $opt_E $opt_e $opt_d/;
use vars qw/$VERSION $REVISION $ERR $OUT $LAST_ID $LOCAL_ID $LOCAL_NODE
            $HELP %HELP
            $xsltparser $parser $encoding $qencoding %doc %files %iconv/;

require Term::ReadLine if $opt_i;

$VERSION='0.5';
$REVISION='$Revision: 1.1.1.1 $';
$ERR='';
$LAST_ID='';
$OUT=\*STDOUT;
$encoding='iso-8859-2';
$qencoding='iso-8859-2';

$HELP=_help();
%HELP=_cmd_help();

$ENV{PERL_READLINE_NOWARN}=1;

sub OK			{ 1 }
sub PARSE_ERROR		{ 2 }
sub INCOMPLETE_COMMAND	{ 3 }

sub files {
  print $OUT map { "$_ = $files{$_}\n" } keys %files;
}

$SIG{PIPE}=sub { #print STDERR "Broken pipe\n"; 

sub sigint {
  print $OUT "\nCtrl-C pressed. \n";
  die "Interrupted by user."; }
};

# prepair and return conversion object
sub mkconv {
  my ($from,$to)=@_;
  $from="utf-8" unless $from ne "";
  $to="utf-8" unless $to ne "";
  if ($iconv{"$from->$to"}) {
    return $iconv{"$from->$to"};
  } else {
    my $conv;
    eval { $conv= Text::Iconv->new($from,$to); }; print STDERR "@_\n" if ($@);
    if ($conv) {
      $iconv{"$from->$to"}=$conv;
      return $conv;
    } else {
      print "Sorry, Iconv cannot convert from $from to $to\n";
      return undef;
    }
  }
}

sub get_local_element {
  my ($id)=@_;
  if ($LOCAL_NODE and $id eq $LOCAL_ID) {
    return $LOCAL_NODE;
  } else {
    return $doc{$id} ? $doc{$id}->getDocumentElement() : undef;
  }
}

sub open_doc {
  my ($id,$file)=@_;
  if ($id eq "" or $file eq "") {
    print STDERR "hint: open identifier=file-name\n" unless "$opt_q";
    return;
  }
  if (-f $file) {
    print STDERR "parsing $file\n" unless "$opt_q";
    $files{$id}=$file;
    eval {
      local $SIG{INT}=\&sigint;
      $doc{$id}=$parser->parse_file($file);
      print STDERR "done.\n" unless "$opt_q";
    }; print STDERR "$@\n" if ($@);
  } else {
    print STDERR "file not exists: $file\n";
  }
}

sub close_doc {
  my ($id)=@_;
  print $OUT "closing file $files{$id}\n" unless "$opt_q";
  delete $files{$id};
  delete $doc{$id};
}

sub save_as {
  my ($id,$file,$enc)=@_;
  my $doc=$doc{$id};
  return unless ref($doc);
  print STDERR "$id=$files{$id} --> $file ($enc)\n" unless "$opt_q";
  $enc=$doc->getEncoding() unless ($enc ne "");
  local *F;
  $file=~/^\s*[|>]/ ? open(F,$file) : open(F,">$file");
#  if ($enc=~/^utf-?8$/i) {
#    eval {
#      local $SIG{INT}=\&sigint;
#      print F $doc->toString(1);
#    }; print STDERR "$@" if ($@);
#    print STDERR "saved $id=$files{$id} as $file in $enc encoding\n" unless "$opt_q";
#  } else {
    eval {
      local $SIG{INT}=\&sigint;
      my $conv=mkconv($doc->getEncoding(),$enc);
      my $t;
      if ($conv) {
	$t=$conv->convert($doc->toString(1));
	$t=~s/(\<\?xml(?:\s+[^<]*)\s+)encoding=(["'])[^'"]+/$1encoding=$2${enc}/;
      } else {
	$t=$doc->toString(1);
      }
      print F $t;
      close F;
      $files{$id}=$file unless $file=~/^\s*[|>]/; # no change in case of pipe
    }; 
  if ($@) {
    print STDERR "$@\n";
  } else {
    print STDERR "saved $id=$files{$id} as $file in $enc encoding\n" unless "$opt_q";
  }
}

sub list {
  my ($id,$query)=@{$_[0]};
  return if ($id eq "" or $query eq "");
  print STDERR "listing $query from $id=$files{$id}\n" unless "$opt_q";
  return unless ref($doc{$id});
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($qencoding,"utf-8");
    my @ql=get_local_element($id)->findnodes($qconv ? $qconv->convert($query) : $query);
    my $conv=mkconv($doc{$id}->getEncoding,$encoding);
    if ($conv) {
      foreach (@ql) {
	print $OUT $conv->convert(ref($_) ? $_->toString() : $_),"\n";
      }
    } else {
      foreach (@ql) {
	print $OUT ((ref($_) ? $_->toString() : $_),"\n");
      }
    }
    print STDERR "\nFound ",scalar(@ql)," nodes.\n" unless "$opt_q";
  }; print STDERR "$@\n" if ($@);;
}

sub count {
  my ($id,$query)=@{$_[0]};
  return if ($id eq "" or $query eq "");
  return unless ref($doc{$id});
  my $count=0;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($qencoding,"utf-8");
    my @l=get_local_element($id)->findnodes($qconv ? $qconv->convert($query) : $query);
    $count=scalar(@l);
  }; print STDERR "$@\n" if ($@);
  return $count;
}

sub prune {
  my ($id,$query)=@{$_[0]};
  return unless ref($doc{$id});
  my $i=0;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($qencoding,"utf-8");

    foreach my $node (get_local_element($id)->
		      findnodes($qconv ? $qconv->convert($query) : $query)) {
      remove_node($node);
      $i++;
    }
    print STDERR "$i nodes removed from $id=$files{$id}\n" unless "$opt_q";
  }; print STDERR "$@" if ($@);
}

sub eval_substitution {
  my $pat;
  ($_,$pat)=@_;
  eval "$pat";
  if ($@) {
    print STDERR "$@\n";
  }
  return $_;
}

sub exec_expr {
  my ($q, $pattern)=@_;
  my ($id,$query)=@{$q};
  my $doc=$doc{$id};
  print STDERR "Executing $pattern on $query in $id=$files{$id}\n" unless "$opt_q";
  unless ($doc) {
    print STDERR "No such document $id\n";
    return;
  }
  eval {
    local $SIG{INT}=\&sigint;

    my $sdoc=get_local_element($id);
    my $qconv=mkconv($qencoding,"utf-8");
    $pattern=$qconv ? $qconv->convert($pattern) : $pattern;

    foreach my $node ($sdoc->findnodes($qconv ? $qconv->convert($query) : $query)) {
      if ($node->nodeType eq XML_ATTRIBUTE_NODE) {
	my $val=$node->getValue();
	$node->setValue(eval_substitution($val,$pattern));
      } elsif ($node->nodeType eq XML_ELEMENT_NODE) {
	my $val=$node->getName();
	$node->setName(eval_substitution($val,$pattern));
      } elsif ($node->can('setData') and $node->can('getData')) {
	my $val=$node->getData();
	$node->setData(eval_substitution($val,$pattern));
      }
    }
  }; print STDERR "$@\n" if ($@);
}

sub insert_node {
  my ($node,$dest,$dest_doc,$where)=@_;
  if ($node->nodeType == XML_TEXT_NODE           ||
      $node->nodeType == XML_CDATA_SECTION_NODE  ||
      $node->nodeType == XML_COMMENT_NODE        ||
      $node->nodeType == XML_PI_NODE             ||
      $node->nodeType == XML_ENTITY_NODE
      and $dest->nodeType == XML_ATTRIBUTE_NODE) {
    my $val=$node->getData();
    $val=~s/^\s+|\s+$//g;
    $dest->getParentNode()->setAttribute($dest->getName(),$val);
  } elsif ($node->nodeType == XML_ATTRIBUTE_NODE) {
    if ($dest->nodeType == XML_ATTRIBUTE_NODE) {
      if ($where eq 'replace') {
	$dest->getParentNode()->setAttribute($node->getName(),$node->getValue());
	$dest->unbindNode();
      } elsif ($where eq 'after') {
	$dest->getParentNode()->setAttribute($dest->getName(),$dest->getValue().$node->getValue());
      } elsif ($where eq "as_child") {
	$dest->getParentNode()->setAttribute($dest->getName(),$node->getValue());
      } else { #before
	$dest->getParentNode()->setAttribute($dest->getName(),$node->getValue().$dest->getValue());
      }
    } elsif ($dest->nodeType == XML_ELEMENT_NODE) {
      $dest->setAttribute($node->getName(),$node->getValue());
    } elsif ($dest->nodeType == XML_TEXT_NODE          ||
	     $dest->nodeType == XML_CDATA_SECTION_NODE ||
	     $dest->nodeType == XML_COMMENT_NODE       ||
	     $dest->nodeType == XML_PI_NODE) {
      if ($where eq 'replace') {
	$dest->setData($node->getValue());
      } elsif ($where eq 'after' or $where eq 'as_child') {
	$dest->setData($dest->getData().$node->getValue());
      } else {
	$dest->setData($node->getValue().$dest->getData());
      }
    }
  } else {
    my $copy=$node->cloneNode(1);
    $copy->setOwnerDocument($dest_doc);
    if ($where eq 'after') {
      $dest->parentNode()->insertAfter($copy,$dest);
    } elsif ($where eq 'as_child') {
      $dest->appendChild($copy);
    } elsif ($where eq 'replace') {
      $dest->parentNode()->insertAfter($copy,$dest);
      $dest->unbindNode();
    } else {
      $dest->parentNode()->insertBefore($copy,$dest);
    }
  }
}

sub copy {
  my ($fid,$fq)=@{$_[0]}; # from ID, from query
  my ($tid,$tq)=@{$_[1]}; # to ID, to query
  my ($where,$all_to_all)=($_[2],$_[3]);

  my $fdoc=$doc{$fid};
  my $tdoc=$doc{$tid};
  return unless (ref($fdoc) and ref($tdoc));
  my (@fp,@tp);
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($qencoding,"utf-8");
    $fq=$qconv ? $qconv->convert($fq) : $fq;
    $tq=$qconv ? $qconv->convert($tq) : $tq;
    @fp=get_local_element($fid)->findnodes($fq);
    @tp=get_local_element($tid)->findnodes($tq);
  } || do { print STDERR "$@\n"; return 0; };
  unless (@tp) {
    print STDERR "No matching nodes found for $tq in $tid=$files{$tid}\n" unless "$opt_q";
    return 0;
  }
  eval {
    local $SIG{INT}=\&sigint;

    if ($all_to_all) {
      my $to=($where eq 'replace' ? 'after' : $where);
      foreach my $tp (@tp) {
	foreach my $fp (@fp) {
	  insert_node($fp,$tp,$tdoc,$to);
	}
	$tp->unbindNode() if $where eq 'replace';
      }
    } else {
      while (ref(my $fp=shift @fp) and ref(my $tp=shift @tp)) {
	insert_node($fp,$tp,$tdoc,$where);
      }
    }
  }; print STDERR "$@\n" if ($@);
  return 1;
}

sub create_attributes {
  my ($exp)=@_;
  my (@ret,$value,$name);
  while ($exp!~/\G$/gsco) {
    if ($exp=~/\G\s*([^\s=]+)=/gsco) {
      my $name=$1;
      print STDERR "attribute_name=$1\n" if $opt_d;
      if ($exp=~/\G"((?:[^\\"]|\\.)*)"/gsco or
	  $exp=~/\G'((?:[^\\']|\\.)*)'/gsco) {
	$value=$1;
	$value=~s/\\(.)/$1/g;
	print STDERR "creating $name=$value attribute\n" if $opt_d;
	push @ret,[$name,$value];
      } else {
	$exp=~/\G(\S*\s*)/gsco;
	print STDERR "ignoring $name=$1\n";
      }
    }
  }
  return @ret;
}

sub create_nodes {
  my ($type,$exp,$doc)=@_;
  my @nodes=();
#  return undef unless ($exp ne "" and ref($doc));
  if ($type eq 'attribute') {
    foreach (create_attributes($exp)) {
      push @nodes,XML::LibXML::Attr->new($_->[0],$_->[1]);
    }
  } elsif ($type eq 'element') {
    my ($name,$attributes);
    if ($exp=~/^\<?(\S+)(\s+.*)?(?:\/?\>?)?\s*$/) {
      print STDERR "element_name=$1\n" if $opt_d;
      print STDERR "attributes=$2\n" if $opt_d;
      my $el=XML::LibXML::Element->new($1);
      if ($2 ne "") {
	foreach (create_attributes($2)) {
	  print "atribute: ",$_->[0],"=",$_->[1],"\n";
	  $el->setAttribute($_->[0],$_->[1]);
	}
      }
      push @nodes,$el;
    } else {
      print STDERR "invalid element $exp\n" unless "$opt_q";
    }
  } elsif ($type eq 'text') {
    push @nodes,XML::LibXML::Text->new($exp);
    print STDERR "text=$exp\n" if $opt_d;
  } elsif ($type eq 'cdata') {
    push @nodes,XML::LibXML::CDATASection->new($exp);
    print STDERR "cdata=$exp\n" if $opt_d;
  } elsif ($type eq 'pi') {
#    my $pi=XML::LibXML::PI->new();
#    $pi->setData($exp);
#    print STDERR "pi=$exp\n" if $opt_d;
#    push @nodes,$pi;
    print STDERR "cannot add PI yet\n" if $opt_d;
  } elsif ($type eq 'comment') {
    push @nodes,XML::LibXML::Comment->new($exp);
    print STDERR "comment=$exp\n" if $opt_d;
  }
  return @nodes;
}

sub insert {
  my ($type,$exp,$xpath,$where,$to_all)=@_;
  my ($tid,$tq)=@{$xpath}; # to ID, to query

  my $tdoc=$doc{$tid};
  return unless ref($tdoc);

  my @nodes=grep {ref($_)} create_nodes($type,$exp,$tdoc);
  return unless @nodes;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($qencoding,"utf-8");
    $tq=$qconv ? $qconv->convert($tq) : $tq;
    my @tp=get_local_element($tid)->findnodes($tq);

    if ($to_all) {
      my $to=($where eq 'replace' ? 'after' : $where);
      foreach my $tp (@tp) {
	foreach my $node (@nodes) {
	  insert_node($node,$tp,$tdoc,$to);
	}
	$tp->unbindNode() if $where eq 'replace';
      }
    } else {
      foreach my $node (@nodes) {
	print "inserting $node $where $tp[0] in $tdoc\n" if $opt_d;
	insert_node($node,$tp[0],$tdoc,$where) if ref($tp[0]);
      }
    }
  }; print STDERR "$@\n" if ($@);
}

sub get_dtd {
  my ($doc)=@_;
  my $dtd;
  eval {
    local $SIG{INT}=\&sigint;
    foreach ($doc->childNodes()) {
      if ($_->nodeType == XML_DTD_NODE) {
	return $_ if ($_->hasChildNodes());
	my $str=$_->toString();
	my $name=$_->getName();
	my $public_id="";
	my $system_id="";
	if ($str=~/PUBLIC\s+(\S)([^\1]*\1)\s+(\S)([^\3]*)\3/) {
	  $public_id=$2;
	  $system_id=$4;
	}
	if ($str=~/SYSTEM\s+(\S)([^\1]*)\1/) {
	  $system_id=$2;
	}
	print STDERR "loading external dtd: $system_id\n" unless "$opt_q";
	$dtd=XML::LibXML::Dtd->new($public_id, $system_id);
	$dtd->setName($name);
	print STDERR "failed to load dtd: $system_id\n" unless ($dtd or "$opt_q");
      }
    }
  }; print STDERR "$@\n" if ($@);
  return $dtd;
}

sub valid_doc {
  my ($id)=@_;
  my $doc;
  my $doc=$doc{$id};
  return unless $doc;
  my $dtd=get_dtd($doc);
  print STDERR "got dtd $dtd\n";
  eval {
    local $SIG{INT}=\&sigint;
    if ($dtd) {
      print $OUT ($doc->is_valid($dtd) ? "yes\n" : "no\n");
    }
  }; print STDERR "$@\n" if ($@);
}

sub validate_doc {
  my ($id)=@_;
  my $doc=$doc{$id};
  return unless $doc;
  my $dtd=get_dtd($doc);
  eval {
    local $SIG{INT}=\&sigint;
    if ($dtd) {
      eval { $doc->validate($dtd); };
      print $OUT "$@\n";
    }
  }; print STDERR "$@\n" if ($@);
}

sub list_dtd {
  my ($id)=@_;
  my $doc=$doc{$id};
  return unless $doc;
  my $dtd=get_dtd($doc);
  eval {
    local $SIG{INT}=\&sigint;
    if ($dtd) {
    my $conv=mkconv($doc->getEncoding(),$encoding);
      print $OUT ($conv ? $conv->convert($dtd->toString()) : $dtd->toString()),"\n";
    }
  };
  print STDERR "$@\n" if ($@);
}

sub print_enc {
  my ($id)=@_;
  my $doc=$doc{$id};
  return unless $doc;
  eval {
    local $SIG{INT}=\&sigint;
    print $OUT $doc->getEncoding(),"\n";
  };
  print STDERR "$@\n" if ($@);
}

sub clone {
  my ($id1,$id2)=@_;
  my $doc=$doc{$id2};
  return if ($id2 eq "" or $id2 eq "" or !ref($doc));
  print STDERR "duplicating $id2=$files{$id2}\n" unless "$opt_q";
  $files{$id1}=$files{$id2};
  eval {
    local $SIG{INT}=\&sigint;
    $doc{$id1}=$parser->parse_string($doc->toString());
  }; print STDERR "$@\n" if ($@);
  print STDERR "done.\n" unless "$opt_q";
}

sub remove_node {
  my ($node)=@_;
  my $sibling=$node->getNextSibling();
  if ($sibling and
      $sibling->nodeType eq XML_TEXT_NODE and
      $sibling->getData =~ /^\s+$/) {
    $sibling->unbindNode;
  }
  $node->unbindNode();
}

sub move {
  my ($src)=@_;
  my @sourcenodes;
  my ($id,$query)=@{$src};
  return unless ref($doc{$id});
  my $i=0;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($qencoding,"utf-8");
    @sourcenodes=get_local_element($id)->
      findnodes($qconv ? $qconv->convert($query) : $query);
  };
  if (copy(@_)) {
    eval {
      local $SIG{INT}=\&sigint;
      foreach my $node (@sourcenodes) {
	remove_node($node);
	$i++;
      }
    };
    print STDERR "$@" if ($@);
  }
}

sub sh {
  eval {
    local $SIG{INT}=\&sigint;
    print $OUT `$_[0]`;
  }; #|| print STDERR "$@\n";
}

sub print_count {
  print $OUT count(@_),"\n";
}

sub run_commands {
  my @cmds=@{$_[0]};
  my ($cmd,@params);
  foreach my $run (@cmds) {
    if (ref($run) eq 'ARRAY') {
      ($cmd,@params)=@$run;
      &{$cmd}(@params);
    }
  }
}

sub pipe_command {
  my ($cmd,$pipe)=@_;
  return unless (ref($cmd) eq 'ARRAY' and $pipe ne '');

  if ($pipe ne '') {
    my $out=$OUT;
    local *PIPE;
    local *O=*$OUT;
    eval {
      open(PIPE,"| $pipe >&O");
      $OUT=\*PIPE;
      run_commands($cmd);
      $OUT=$out;
      close PIPE;
    }; print STDERR "$@\n" if ($@);
  }
}

sub while_statement {
  my ($xp,$command)=@_;
  do {
    run_commands($command)
  } while(count($xp)>1);
}

sub foreach_statement {
  my ($xp,$command)=@_;
  my ($id,$query)=@$xp;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($qencoding,"utf-8");
    $query=$qconv ? $qconv->convert($query) : $query;
    $LOCAL_ID=$id;
    foreach $LOCAL_NODE ($doc{$id}->documentElement()->findnodes($query)) {
      run_commands($command)
    }
  }|| print STDERR "$@\n";
}

sub if_statement {
  my ($xp,$command)=@_;
  run_commands($command) if (count($xp)>0);
}

sub unless_statement {
  my ($xp,$command)=@_;
  run_commands($command) unless (count($xp));
}

sub xslt {
  my ($id,$stylefile,$newid,$params)=@_;
  print STDERR "running xslt on @_\n";
  return unless $doc{$id};
  eval {
    my %params=map { split /=/,$_,2 } split /\s+/,$params;
    local $SIG{INT}=\&sigint;
    if (-f $stylefile) {
      require XML::LibXSLT;

      local *SAVE;
      local *O=*$OUT;
      open (SAVE,">&STDERR");
      open (STDERR,">/dev/null");

      my $xsltparser=XML::LibXSLT->new();
#      unless ($xsltparser) {
#	$xsltparser=XML::LibXSLT->new();
#      }
      my $st=$xsltparser->parse_stylesheet_file($stylefile);
      $doc{$newid}=$st->transform($doc{$id},%params);
      $stylefile=~s/\..*$//;
      $files{$newid}="$stylefile"."_transformed_".$files{$id};

      open (STDERR,">&SAVE");
      close SAVE;

    } else {
      die "File not exists $stylefile\n";
    }
  }; print STDERR "$@\n" if ($@);
}

sub help {
  my ($command)=@_;
  if ($command) {
    if (exists($HELP{$command})) {
      print $OUT $HELP{$command};
    } else {
      print $OUT "no detailed help available on $command\n";
    }
  } else {
    print $OUT $HELP;
  }
}


if ($opt_h) {
  print "Usage: $0 [-q] [-e output-encoding] [-E query-encoding] <commands>\n";
  print "or $0 -h $0 -V\n\n";
  print "   -e   output encoding (default is the document encoding)\n";
  print "   -E   query encoding (default is the output encoding)\n\n";
  print "   -q   quiet\n\n";
  print "   -i   interactive\n\n";
  print "   -d   print debug messages\n\n";
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

$Parse::RecDescent::skip = '\s*';


my $xsh = Parse::RecDescent->new(<<'_EO_GRAMMAR_'
  STRING: /([^'"\\ ]|\\.)([^ \\]|\\.)*/
     { local $_=$item[1];
       s/\\(.)/$1/g;
       $_;
     }
  QUOTEDSTRING: /\"([^\"\\]|\\.)*\"|\'([^\'\\]|\\.)*\'/
     { local $_=$item[1];
       s/^["']|["']$//g;
       s/\\(.)/$1/g;
       $_;
     }

  ID: /\w+/

  startrule : statement

  statement : shell
            | commands '|' cmdline { main::pipe_command($item[1],$item[3]); }
            | commands { main::run_commands($item[1]); }
            | /quiet/ { $main::opt_q=1 }
            | /verbose/ { $main::opt_q=0 }
            | /debug/ { $main::opt_d=1 }
            | /nodebug/ { $main::opt_d=0 }
            | /encoding\s/ expression { $main::encoding=$item[2]; }
            | /query-encoding\s/ expression { $main::qencoding=$item[2]; }
  commands : command ';' commands { [ @{$item[1]},@{$item[3]} ]; }
           | command

  command_or_block : command
                   | '{' commands '}' { $item[2]; }

  command   : (copy_command | move_command | list_command | exit_command
            | prune_command | exec_command | close_command | open_command
            | valid_command | validate_command | list_dtd_command | print_enc_command
            | clone_command | count_command | save_command
            | files_command | xslt_command | insert_command | help_command
            | exec_command
            | compound)
            { [$item[1]] }

  compound  : /if\s/ xpath command_or_block { [\&main::if_statement,$item[2],$item[3]] }
            | /unless\s|if\s+!/ xpath command_or_block { [\&main::unless_statement,$item[2],$item[3]] }
            | /while\s/ xpath command_or_block {
              [\&main::while_statement,$item[2],$item[3]];
            }
            | /foreach\s/ xpath command_or_block {
              [\&main::foreach_statement,$item[2],$item[3]];
            }


  help_command : /\?|help\s/ /[a-z]*/ { [\&main::help,$item[2]]; }
               | /\?|help/ { [\&main::help]; }

  exec_command : /exec\s|system\s/ expression
               { [\&main::sh,$item[2]] }

  xslt_command : xslt_alias ID filename ID /params|parameters\s/ expression
               { [\&main::xslt,@item[2,3,4,6]]; }
               | xslt_alias ID filename ID
               { [\&main::xslt,@item[2,3,4]]; }

  xslt_alias : /transform\s|xslt?\s|xsltproc\s|process\s/

  files_command : 'files' { [\&main::files]; }
  shell : /!\s*/ cmdline { main::sh($item[2]); }

  cmdline : /.*$/

  copy_command : /cp\s|copy\s/ xpath loc xpath { [\&main::copy,@item[2,4,3]]; }
               | /xcp\s|xcopy\s/ xpath loc xpath { [\&main::copy,@item[2,4,3],1]; }

  insert_command : /insert\s|add\s/ nodetype expression loc xpath
                 { [\&main::insert,@item[2,3,5,4]]; }
                 | /xinsert\s|xadd\s/ nodetype expression loc xpath
                 { [\&main::insert,@item[2,3,5,4],1]; }

  nodetype       : /element|attribute|attributes|text|cdata|pi|comment/

  loc : "after"
      | "before"
      | "to"          { "as_child" }
      | "into"        { "as_child" }
      | "as child of" { "as_child" }
      | "as child"    { "as_child" }
      | "replace"
      | "instead of"  { "replace" }
      | "instead"     { "replace" }

  move_command : /mv\s|move\s/ xpath loc xpath
                  { [\&main::move,@item[2,4,3]]; }
               | /xmv\s|xmove\s/ xpath loc xpath
                  { [\&main::move,@item[2,4,3],1]; }

  clone_command : /dup\s|clone\s/ ID /\s*=\s*/ ID { [\&main::clone,@item[2,4]]; }

  list_command : /list\s|ls\s/ xpath    { [\&main::list,$item[2]]; }

  count_command : /count\s/ xpath       { [\&main::print_count,$item[2]];}

  prune_command : /rm\s|remove\s|prune\s|delete\s|del\s/ xpath  { [\&main::prune,$item[2]]; }

  exec_command : /on\s|sed\s/ xpath perl_expression
				       { [\&main::exec_expr,@item[2,3]]; }

  close_command : /close\s/ ID
				       { [\&main::close_doc,$item[2]]; }

  open_command : /open\s/ ID /\s*=\s*/ filename
				       { $main::LAST_ID=$item[2];
                                         [\&main::open_doc,@item[2,4]]; }
               | ID /\s*=\s*/ filename
				       { $main::LAST_ID=$item[1];
                                         [\&main::open_doc,@item[1,3]]; }

  save_command : /saveas\s/ ID filename /encoding\s/ expression
                                       { $main::LAST_ID=$item[2];
                                         [\&main::save_as,@item[2,3,5]]; }
               | /saveas\s/ ID filename
                                       { $main::LAST_ID=$item[2];
                                         [\&main::save_as,@item[2,3]]; }
               | /save\s/ ID /encoding\s/
                                       { $main::LAST_ID=$item[2];
                                         [\&main::save_as,$item[2],$main::files{$item[2]},
                                                       $item[4]]; }
               | /save\s/ ID           { $main::LAST_ID=$item[2];
                                         [\&main::save_as,$item[2],$main::files{$item[2]}]; }

  list_dtd_command : /dtd\s/ ID        { $main::LAST_ID=$item[2];
                                         [\&main::list_dtd,$item[2]]; }
                   | /dtd(\s|$)/       { [\&main::list_dtd,$main::LAST_ID] }


  print_enc_command: /enc\s/ ID        { $main::LAST_ID=$item[2];
                                         [\&main::print_enc,$item[2]]; }
                   | /enc(\s|$)/       { [\&main::print_enc,$main::LAST_ID] }

  validate_command : /validate\s/ ID   { $main::LAST_ID=$item[2];
                                         [\&main::validate_doc,$item[2]]; }
                   | /validate(\s|$)/  { [\&main::validate_doc,$main::LAST_ID] }

  valid_command : /valid\s/ ID         { $main::LAST_ID=$item[2];
                                         [\&main::valid_doc,$item[2]]; }
                | /valid(\s|$)/        { [\&main::valid_doc,$main::LAST_ID] }

  exit_command : /exit|quit/                { exit(0); }

  filename : expression

  xpath : ID ":" expression { $main::LAST_ID=$item[1]; [@item[1,3]] }
        | expression { [$main::LAST_ID, $item[1]] }

  perl_expression : expression

  expression : STRING | QUOTEDSTRING


_EO_GRAMMAR_
);

$parser = XML::LibXML->new();
$parser->load_ext_dtd(1);
$parser->validation(1);

my @string=split /;/, join " ",@ARGV;
my $l;

if ($opt_i) {
  my $rev=$REVISION;
  $rev=~s/\s*\$//g;
  $rev=" xsh - XML Editing Shell version $VERSION ($rev)\n";
  print STDERR "-"x length($rev),"\n";
  print STDERR $rev;
  print STDERR "-"x length($rev),"\n\n";
}

if (@string) {
  foreach (@string) {
    print "xsh> $_\n";
    $xsh->startrule($_);
    print "\n";
  }
}

if ($opt_i) {
  my $term;
  $term = new Term::ReadLine 'xsh';
  $OUT = $term->OUT || $OUT;
  print STDERR "Using terminal type: ",$term->ReadLine,"\n" unless "$opt_q";
  print STDERR "Hint: Type `help' or `help | less' to get more help.\n";
  while (defined ($l = $term->readline('xsh> '))) {
    while ($l=~/\\+\s*$/) {
      $l=~s/\\+\s*$//;
      $l .= $term->readline('> ');
    }
    $xsh->startrule($l);
    $term->addhistory($l) if /\S/;
  }
} elsif (!@string) {
  while ($l=<>) {
    chomp $l;
    while ($l=~/\\+\s*$/) {
      $l=~s/\\+\s*$//;
      $l .= <>;
      chomp $l;
    }
    $xsh->startrule($l);
  }
}
print STDERR "Good bye!\n" unless "$opt_q";

sub _help {
  return <<'EOH';
General notes:
 - More than one command may be used on one line. In that case
   the commands must be separated by semicolon which has to be
   preceded by whitespace.
 - Any command or set of commands may be followed by a pipeline filter
   (like in a Unix shell) to process its output, so for example

     xsh> list //words/attribute() | grep foo | wc

   counts any attributes that contain string foo in its name or value.
 - Many commands have aliases. See help <command> for a list.
 - Parameters containing spaces *must* be quoted with single- or
   double-quotes; thus for example: list "//words[text() and
   @foo='\"bar\"']" is correct but list //words[text() and @foo='bar']
   is not.
 - Use slash in the end of line to indicate that the command follows
   on next line.

Parameter types:
  <command>                  - one of the commands described bellow.
  <block>                    - a command or a block of whitespace and semicolon
                               separated commands enclosed in '{','}' brackets.
  <id>                       - a symbolic document identifier.
  <xpath>                    - an XPath expression optionally prefixed with
                               an <id> identifier followed by colon to address
                               a specific document (<id>:xpath-expression). If
                               no <id> is given, the most recently addressed or
                               opened document is used.
  <filename>                 - a filename (if should contain spaces,
                               use single- or double-quotes).
  <loc>                      - location: one of after, before, into, replace
  <type>                     - node type: one of element, attribute, text,
                               cdata, comment
  <encoding>                 - like encoding string in XML declaration
                               (e.g. utf-8)

Available commands:
  [open] <id>=<filename>     - Open and parse given XML document. The document
                               may be later addressed by its <id>.
  close <id>                 - Close document identified by <id>.
  clone <id>=<id>            - duplicate an existing document under a new
                               identifier
  save <id> [encoding <enc>] - save given document in given or its original
                               encoding
  saveas <id> <filename> [encoding <enc>]
                             - save document identified by <id> in a given file

  files                      - list open files and their identifiers.

  ! shell-command            - execute a given shell command (as ! in ftp).
                               The shell command is considered to span
                               to the end of line

  exec "shell-command"       - execute a given shell command. If the
                               command-line should contain whitespace
                               (i.e. to specify arguments), you must
                               enclose it into single- or double-quotes.

  copy <xpath> <loc> <xpath> - copy nodes (one-to-one)
  xcopy <xpath> <loc> <xpath>- copy nodes (every-to-every)
  move <xpath> <loc> <xpath> - move nodes (one-to-one)
  xmove <xpath> <loc> <xpath>- move nodes (every-to-every)

  add <type> <node> <loc> <xpath> - create a new node (in the first
                                    matched location)
  xadd <type> <node> <loc> <xpath> - create new node(s) (in all
                                     matched locations)
  remove <xpath>             - delete all matching nodes

  on <xpath> <perl-code>     - process every matched text or cdata node,
                               attribute value, element name or
                               command by given perl-code

  transform <id> <file> <id> [params <expression>]
                             - transform the first document using a
                               XSLT stylesheet file <file> and create
                               a new document with the <id> specified
                               in the third parameter. To pass
                               parameters to the stylesheet follow the
                               command with: params "name1='value1'
                               name2='value2'..."

  list <xpath>               - list all matching nodes
  count <xpath>              - print number of matching nodes
  dtd <id>                   - print DTD for a given document
  enc <id>                   - print the document encoding string

  valid <id>                 - return yes/no string if the document is
                               valid or not.

  validate <id>              - validate the given document and output
                               any error messages.

  if <xpath> <block>         - run commands if <xpath> matches at least
                               one element.
  unless <xpath> <block>     - run commands if <xpath> matches no element.
  while <xpath> <block>      - repeat commands while <xpath> matches at least
                               one element.
  foreach <xpath> <block>    - run a commands on each of the nodes matching
                               given xpath.

  help <command>             - get more detailed help on a command.
                               (Sorry, no help on aliases yet).
  exit                       - exit xsh.
EOH
}

sub _cmd_help {
  return ('help' => <<'H1',
usage:       help <command>

aliases:     help, ?

description: Print help on a given command.

H1

'exit' => <<'H1',
usage:       exit

aliases:     exit, quit

description: Exit xsh immediately (no files are saved).

H1

'foreach' => <<'H1',
usage:       foreach <xpath> <command>

description: Execute the command for each of the nodes matching the given
             XPath expression so that all relative XPath expressions
             of the command relate to the selected node.

example:     xsh> foreach //company xmove ./employee into ./staff
             moves all employee elements in a company element into
             a staff subelement of the same company

H1

'while' => <<'H1',
usage:       while <xpath> <command>

description: Execute <command> as long as there is any node matching <xpath>

example:     the result of 
             xsh> while /table/row del /table/row[1]
             is equivalent to the result of
             xsh> del /table/row

H1

'unless' => <<'H1',
usage:       unless <xpath> <command>

aliases:     "if !"

description: Execute <command> only if no node matches <xpath>.

H1

'if' => <<'H1',
usage:       if <xpath> <command>

description: Execute <command> if there is a match for <xpath>.

H1

'validate' => <<'H1',
usage:       validate [<id>]

description: Try to validate given document according to its DTD,
             report all validity errors.
             If no document identifier is given, the document
             last used in an Xpath expression or a command
             is used.

see also:    valid, dtd

H1

'valid' => <<'H1',
usage:       valid [<id>]

description: Check and report the validity of a document.
             Prints "yes" if the document is valid and "no" otherwise.
             If no document identifier is given, the document
             last used in an Xpath expression or a command
             is used.

see also:    validate, dtd

H1
'dtd' => <<'H1',
usage:       dtd [<id>]

description: Print external or internal DTD for the given document.
             If no document identifier is given, the document
             last used in an Xpath expression or a command
             is used.

see also:    valid, validate

H1
'dtd' => <<'H1',
usage:       enc [<id>]

description: Print the original document encoding string.
             If no document identifier is given, the document
             last used in an Xpath expression or a command
             is used.

H1
'count' => <<'H1',
usage:       count <xpath>

description: print number of nodes matching <xpath>

see also:    list

H1
'list' => <<'H1',
usage:       list <xpath>

aliases:     ls

description: List the XML representation of all elements matching <xpath>.
             Unless in quiet mode, print number of nodes matched on stderr.

see also:    count

H1
'transform' => <<'H1',
usage:       transform <id> <file> <id> [params <expression>]

aliases:     xslt, xsl, xsltproc, process

description: Load an XSLT stylesheet from <file> and use it to
             transform the document of the first <id> into a new
             document named <id>. Parameters may be passed to a
             stylesheet after params keyword in the form name='value'.
             However, if the parameter values contain spaces or there
             is more than one parameter passed, you must enclose the
             whole <expression> into single- or double-quotes (and
             backslash-quote all quotes within).

H1
'on' => <<'H1',
usage:       on <xpath> <perl-expression>

aliases:     sed

description: Each of the nodes matching <xpath> is processed with the
             <perl-expression> in the following way: if the node is an
             element, its name is processed, if it is an attribute,
             its value is used, if it is a cdata section, text node,
             comment or processing instruction, its data is used.  The
             expression should expect the data in the $_ variable and
             should use the same variable to store the modified data.
             If <perl-expression> should contain spaces, you must
             enclose the whole <expression> into single- or
             double-quotes (and backslash-quote all quotes within).

examples:    xsh> on //hobbit $_='halfling'
             renames all hobbits to halflings

             xsh> on //hobbit/@name $_=ucfirst($_)
             capitalises all hobbit names

             xsh> on //hobbit/tale/text() s/goblin/orc/gi
             replaces all goblin with orcs in all hobbit tales.

H1
'remove' => <<'H1',
usage:       remove <xpath>

aliases:     delete, del, rm, prune

description: Remove all nodes matching <xpath>.

example:     xsh> del //creature[@manner='evil']
             get rid of all evil creatures

H1
'xadd' => <<'H1',
usage:       xadd <type> <node> <loc> <xpath>

aliases:     xinsert

description: Create new nodes of type <type> in the location <loc>
             related to every node matching <xpath>. If the type is
             element, the format of <node> expression should be
             "<element-name [att-name='attvalue' ...]>".  To create an
             element without attributes, use just element-name. Note,
             that quotes are always obligatory if <node> expression
             contains spaces.  Attribute nodes use the following
             syntax: "att-name='attvalue' [...]"  For other types of
             nodes (text, cdata, comments) the <node> expression
             should contain their literal content data and should be
             quoted unless it contains no whitespace.  The <loc>
             directive should be one of: after, before, into and
             replace. To attach an attribute to an element, into
             should be used as <loc>. The into <loc> may also be used
             to append data to a text, cdata or comment node.  Note
             also, that the after and before <loc> directives do not
             apply to attributes.

example:     xsh> xadd element "<creature race='hobbit' manner='good'> \
                  into /middle-earth/creatures
             append a new hobbit element to the list of middle-earth creatures

             xsh> xadd attribute "name='Bilbo'" \
                  into /middle-earth/creatures/creature[@race='hobbit'][last()]
             name the last hobbit Bilbo

see also:    add, move, xmove
H1
'xadd' => <<'H1',
usage:       add <type> <node> <loc> <xpath>

aliases:     insert

description: Works just like xadd, except that the new node
             is attached only the first node matched.

see also:    xadd, move, xmove
H1
'copy' => <<'H1',
usage:       copy <xpath> <loc> <xpath>

aliases:     cp

description: Copies nodes matching the first <xpath> to the
             destinations determined by the <loc> directive relative
             to the second <xpath>. If more than one node matches the
             first <xpath> than it is copied to the position relative
             to the corresponding node matched by the second <xpath>
             according to the order in which are nodes matched. Thus,
             the n'th node matching the first <xpath> is copied to the
             location relative to the n'th node matching the second
             <xpath>. The possible values for <loc> are: after,
             before, into, replace and cause copying the source nodes
             after, before, into (as the last child-node).  the
             destination nodes. If replace <loc> is used, the source
             node is copied before the destination node and the
             destination node is removed.

             Some kind of type conversion is used when the types of
             the source and destination nodes are not equal.  Thus,
             text, cdata, comment or processing instruction node data
             prepend, append or replace value of a destination
             attribute when copied before,after/into or instead
             (replace) an attribute, and vice versa.

             Attributes may be copied after, before or into some other
             attribute to append, prepend or replace the destination
             attribute value. They may also replace the destination
             attribute completely (both its name and value).

             To simply copy an attribute from one element to another,
             simply copy the attribute node into the destination
             element.

             Elements may be copied into other elements (which results
             in appending the child-list of the destination element),
             or before, after or instead (replace) other nodes of any
             type except attributes.

examples:    xsh> copy a://creature replace b://living-thing
             replace every libing-thing element in the document b
             with the coresponding creature element of the document a.

see also:    xcopy, add, xadd, move, xmove
H1
'xcopy' => <<'H1',
usage:       xcopy <xpath> <loc> <xpath>

aliases:     xcp

description: xcopy is similar to copy, but copies *all* nodes matching
             the first <xpath> to *all* destinations determined by the
             <loc> directive relative to the second <xpath>. See copy
             for detailed description of xcopy arguments.

examples:    xsh> xcopy a:/middle-earth/creature into b://world
             copy all middle-earth creatures within the document a
             into every world of the document b.

see also:    copy, add, xadd, move, xmove
H1
'move' => <<'H1',
usage:       move <xpath> <loc> <xpath>

aliases:     mv

description: like copy, except that move removes the source nodes
             after a succesfull copy. See copy for more detail.

see also:    copy, xmove, add, xadd
H1
'xcopy' => <<'H1',
usage:       xmove <xpath> <loc> <xpath>

aliases:     xmv

description: like xcopy except that xmove removes the source nodes
             after a succesfull copy. See xcopy for more detail.

see also:    xcopy, move, add, xadd
H1
'exec' => <<'H1',
usage:       exec <expression>

aliases:     system

description: execute the system command(s) in <expression>.
             If <expression> should contain spaces, it must
             be quoted in single- or double- quotes.

examples:    exec "echo hallo word | wc"; exec uname
             count words in "hallo wold" string, then print
             name of your machine's operating system.

see also:    !
H1
'!' => <<'H1',
usage:       ! <shell-commands>

description: execute the given system command(s). The arguments
             of ! are considered to begin just after the ! character
             and span across the whole line.

examples:    !ls
             list current directory
             !ls | grep \\.xml$
             is equivalent to
             !ls *.xml

see also:    exec
H1
'files' => <<'H1',
usage:       files

description: List open files and their identifiers.

see also:    open, close
H1
'saveas' => <<'H1',
usage:       saveas <id> <filename> [encoding <enc>]

description: Save the document identified by <id> as a XML file named
             <filename>, possibly converting it from its original encoding
             to <enc>.

see also:    open, close, enc
H1
'save' => <<'H1',
usage:       save <id> [encoding <enc>]

description: Save the document identified by <id> to its original XML
             file, possibly converting it from its original encoding
             to <enc>.

see also:    open, close, enc, files
H1
'clone' => <<'H1',
usage:       clone <id>=<id>

description: Make a copy of the document identified by the <id>
             following the equal sign assigning it the identifier of
             the first <id>.

see also:    open
H1
'close' => <<'H1',
usage:       close <id>

description: Close the document identified by <id>, removing its
             parse-tree from memory.

see also:    save, open
H1
'open' => <<'H1',
usage:       open <id>=<filename>

aliases:     <id>=<filename>

description: Open a new document assigning it a symbolic name of <id>.
             To identify the document, use simply <id> in commands
             like close, save, validate, dtd or enc. In commands which
             work on document nodes, use <id>: prefix is XPath
             expressions to point the XPath into the document.

examples:    xsh> open x=mydoc.xml
             open a document

             xsh> open y="document with a long name with spaces.xml"
             quote file name if it contains whitespace

             xsh> z=mybook.xml
             you may omit the word open (I'm clever enough to find out).

             xsh> list z://chapter/title
             use z: prefix to identify the document opened with the previous
             comand in an XPath expression.

see also:    save, close, clone
H1


);
}
