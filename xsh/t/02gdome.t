# -*- cperl -*-
use Test;

BEGIN {
  plan tests => 0;
  exit;

  @xsh_test=split /\n\n/, <<'EOF';
list | wc

count /;

insert element foo into /*;

count count(//foo)>0;

assign $bar=0;

count $bar=0;

while count(//foo)<10 { insert element "<foo bar='$bar\' count=${{count(//foo)}}" into /*; $bar=$bar+1 };

count count(//foo)=10;

insert attribute bar=8 into //foo[3]

count count(//foo[@bar="8"])=2;

map { $_=1 } //foo[3]/@bar

count count(//foo[@count and @bar=string(@count)-1])>0;

perl { 1+1; };

exec ls -l;

! echo -n " sh test: "; echo " (success)";

clone t=scratch;

list | wc;

def myfunc { defs; encoding iso-8859-2; };

call myfunc;

files;

foreach scratch://foo { insert text "no. " into .; copy ./@bar append ./text() };

indent 1;

if count(//foo/text()[starts-with(.,'no. 8')])!=1 { eval die };

map $_=uc //foo/text();

unless count(//foo/text()[starts-with(.,'NO. 8')])=1 { eval die };

count count(//foo)=10

if 1+1!=2 { eval die } else { unless (1+2!=3) { eval 1 } else { eval die } };

if 1+1=2 { unless 1+2=3 { eval die } else { eval 1 } } else { eval die };

test-mode; eval die;

run-mode;

move scratch://foo[not(@bar)] into t://foo[@bar='1'];

count scratch:count(/scratch/foo)=9;

count t:count(/scratch/foo/foo)=1;

locate //foo | cat

cd t:/scratch/foo/foo/text()

pwd | cat

remove t://foo/foo;

pwd | cat

count t:count(/scratch/foo/foo)=0;

select scratch;

count t:count(//foo)=10;

create new1 test

count count(//*)=1;

create new2
"<?xml version='1.0' encoding='iso-8859-1'?>
<!DOCTYPE root [
  <!ELEMENT root (#PCDATA | br)*>
  <!ATTLIST root id ID #REQUIRED>
  <!ELEMENT br EMPTY>
]>
<root id='root1'>
My test document <br/>is quite nice and <br/>simple.
</root>
"

count id('root1');
count //root;
count count(//br)=2;
count //text()[contains(.,'simple')];

xinsert element silly after //br

count count(//br[./following-sibling::silly])=2

ls scratch:/ | cat;
ls t:/ | cat;
ls new1:/ | cat;
ls new2:/ | cat

select t

close t

ls / | cat
EOF

  if (eval { require XML::GDOME; } ) {
    plan tests => 5+@xsh_test;
  } else {
    plan tests => 1;
    $no_gdome=1;
  }
}
END {
  skip($no_gdome,$loaded);
}
unless ($no_gdome) {
  require XML::XSH;
  import XML::XSH qw/&xsh &xsh_init &set_quiet &xsh_set_output/;
  $loaded=1;
  ok(1);

  my $verbose=$ENV{HARNESS_VERBOSE};

  ($::RD_ERRORS,$::RD_WARN,$::RD_HINT)=(1,1,1);

  $::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
  $::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
  $::RD_HINT   = 1;		# Give out hints to help fix problems.

  xsh_set_output(\*STDERR);
  set_quiet(0);

  xsh_init("XML::XSH::GDOMECompat");

  print STDERR "\n" if $verbose;
  ok(1);

  print STDERR "\n" if $verbose;
  ok ( XML::XSH::Functions::create_doc("scratch","scratch") );

  print STDERR "\n" if $verbose;
  ok ( XML::XSH::Functions::set_local_xpath(['scratch','/']) );

  foreach (@xsh_test) {
    print STDERR "\n\n[[ $_ ]]\n" if $verbose;
    ok( xsh($_) );
  }
}
