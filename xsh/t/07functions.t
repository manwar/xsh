# -*- cperl -*-
use Test;

use IO::File;

BEGIN {
  autoflush STDOUT 1;
  autoflush STDERR 1;

  @xsh_test=split /\n\n/, <<'EOF';
quiet;
def x_assert $cond
{ perl { xsh("unless ($cond) throw concat('Assertion failed ',\$cond)") } }
call x_assert '/scratch';
try {
  call x_assert '/xyz';
  throw "x_assert failed";
} catch local $err {
  unless { $err =~ /Assertion failed \/xyz/ } throw $err;
};

$doc2 := create 'foo';
insert text 'scratch' into ($doc2/foo);

#function xsh:var
$var=//node();

call x_assert 'count(xsh:var("var"))=2';

call x_assert 'name(xsh:var("var")[1])="foo"';

call x_assert 'xsh:var("var")[2]/self::text()';

call x_assert 'xsh:var("var")[2]="scratch"';

#function xsh:matches
call x_assert 'xsh:matches("foo","^fo{2}$")';

call x_assert 'not(xsh:matches("foo","O{2}"))';

call x_assert 'not(xsh:matches("foo","O{2}",0))';

call x_assert 'xsh:matches("foo","O{2}",1)';

call x_assert 'xsh:matches(/foo,"^sCR.tch$",1)';

call x_assert 'not(xsh:matches(/foo,"foo",1))';

#function xsh:substr
call x_assert 'xsh:substr("foobar",3)="bar"';

call x_assert 'not(xsh:substr("foobar",3)="baz")';

call x_assert 'xsh:substr("foobar",0,3)="foo"';

call x_assert 'xsh:substr("foobar",-2)="ar"';

call x_assert 'xsh:substr("foobar",-4,3)="oba"';

call x_assert 'xsh:substr(/,1)="cratch"';

call x_assert 'xsh:substr(/foo,1)="cratch"';

#function xsh:reverse
call x_assert 'xsh:reverse("foobar")="raboof"';

call x_assert 'xsh:reverse(/foo)="hctarcs"';

call x_assert 'xsh:reverse(/foo/text())="hctarcs"';

#function xsh:grep
call x_assert 'count(xsh:grep(//node(),"."))=2';

call x_assert 'count(xsh:grep(//node(),"^scr"))=2';

call x_assert 'xsh:grep(//node(),".")=xsh:grep(//node(),"^scr")';

call x_assert 'not(xsh:grep(//node(),".")=xsh:grep(//node(),"^Scr"))';

call x_assert 'xsh:grep(//node(),".")=xsh:grep(//node(),"(?i)Scr")';

call x_assert 'xsh:grep(//node(),".")/self::foo';

call x_assert 'xsh:grep(//node(),".")/self::text()';

call x_assert 'not(xsh:grep(//node(),"foo"))';

call x_assert 'xsh:grep(//node(),".")[.="scratch"]';


call x_assert 'xsh:grep(//node(),"scratch")[.="scratch"]';

#function xsh:same
call x_assert 'xsh:same(//node(),/foo)';

call x_assert 'xsh:same(/foo,/foo)';

call x_assert 'not(xsh:same(/foo,/foo/text()))';

call x_assert 'not(xsh:same(/bar,/baz))';

call x_assert 'not(xsh:same(/foo,/bar))';

call x_assert 'xsh:same(/*,$doc2/*)';

#function xsh:max
$doc3 := create '<a><b>4</b><b>-3</b><b>2</b></a>';

call x_assert 'xsh:max(//b)=4';

call x_assert 'xsh:max(//b/text())=4';

call x_assert 'xsh:max(//a/text())=0';

call x_assert 'xsh:max(//b[1],//b[3])=4';

call x_assert 'xsh:max(-4,2,7)=7';

call x_assert 'xsh:max(3,9,7)=9';

call x_assert 'xsh:max(-4,-9,0)=0';

#function xsh:min
$doc3 := create '<a><b>4</b><b>-3</b><b>2</b></a>';

call x_assert 'xsh:min(//b)=-3';

call x_assert 'xsh:min(//b/text())=-3';

call x_assert 'xsh:min(//a/text())=0';

call x_assert 'xsh:min(//b[1],//b[2])=-3';

count string(//b[1]);

count string(//b[3]);

count (xsh:min(//b[1],//b[3]));

call x_assert 'xsh:min(//b[1],//b[3])=2';

call x_assert 'xsh:min(-4,2,7)=-4';

call x_assert 'xsh:min(3,9,7)=3';

call x_assert 'xsh:min(3,9,0)=0';

#function xsh:sum
call x_assert 'xsh:sum(//node())=4+4-3+2+4-3+2';

call x_assert 'xsh:sum(//b)=3';

call x_assert 'xsh:sum(//b/text())=3';

call x_assert 'xsh:sum(//b[1],//b[3])=6';

rm //b[2];

call x_assert 'xsh:sum(//b)=6';

call x_assert 'xsh:sum(//node())=42+4+2+4+2';

call x_assert 'xsh:sum(0)=0';

call x_assert 'xsh:sum(3,4,5)=12';

call x_assert 'xsh:sum(-3,4,-5)=-4';

#function xsh:strmax
$doc3 := create '<a><b>abc</b><b>bde</b><b>bbc</b></a>';

call x_assert 'xsh:strmax(//a)="abcbdebbc"';

call x_assert 'xsh:strmax(//b)="bde"';

call x_assert 'xsh:strmax(//b/text())="bde"';

call x_assert 'xsh:strmax(//b[1],//b[3])="bbc"';

#function xsh:strmin
$doc3 := create '<a><b>abc</b><b>bde</b><b>bbc</b></a>';

call x_assert 'xsh:strmin(//a)="abcbdebbc"';

call x_assert 'xsh:strmin(//b)="abc"';

call x_assert 'xsh:strmin(//b/text())="abc"';

call x_assert 'xsh:strmin(//b[2],//b[3])="bbc"';

#function xsh:join
call x_assert 'xsh:join("",//b)="abcbdebbc"';

call x_assert 'xsh:join(":",//b)="abc:bde:bbc"';

call x_assert 'xsh:join(//b,//b)="abcabcbdebbcbdeabcbdebbcbbc"';

call x_assert 'xsh:join(";;",//b[1],//b,//b[3])="abc;;abc;;bde;;bbc;;bbc"';

#function xsh:serialize
$xml = '<a>abc<!--foo--><?bar bug?> <dig/></a>';

$doc3 := create $xml;

call x_assert 'xsh:serialize(//dig)="<dig/>"';

call x_assert 'xsh:serialize(//a/text()[1])="abc"';

call x_assert 'xsh:serialize(//a/comment())="<!--foo-->"';

call x_assert 'xsh:serialize(//a/processing-instruction())="<?bar bug?>"';

call x_assert 'xsh:serialize(/a)="${xml}"';

call x_assert 'xsh:serialize(//*)="${xml}<dig/>"';

call x_assert 'xsh:serialize(//node())="${xml}abc<!--foo--><?bar bug?> <dig/>"';
call x_assert 'xsh:serialize(/a,//dig,//text())="${xml}<dig/>abc "';

#function xsh:subst
$doc4 := create '<a>abcb</a>';

call x_assert 'xsh:subst("foo","fo",12)="12o"';

call x_assert 'xsh:subst("foo","o","XY")="fXYo"';

count (xsh:subst("foo","O","XY"));

call x_assert 'xsh:subst("foo","O","XY")="foo"';

call x_assert 'xsh:subst("foo","O","XY","i")="fXYo"';

call x_assert 'xsh:subst("foo","O","XY","ig")="fXYXY"';

call x_assert 'xsh:subst("foobar","f(.*b)a(.+)","$1-$2")="oob-r"';

call x_assert 'xsh:subst("foobar","(.{2}b)","uc($1)","e")="fOOBar"';

call x_assert 'xsh:subst("foobar","o","/","g")="f//bar"';

call x_assert 'xsh:subst("foobar","o","[\\]","g")="f[\][\]bar"';

call x_assert 'xsh:subst(/a,"b","X","g")="aXcX"';

#function xsh:sprintf
call x_assert 'xsh:sprintf("%%")="%"';

call x_assert 'xsh:sprintf("%d",123.3)="123"';

call x_assert 'xsh:sprintf("%04d",13.3)="0013"';

count (xsh:sprintf("%03.4d",13.123)) |cat 2>&1;

call x_assert 'xsh:sprintf("%09.4f",13.123)="0013.1230"';

call x_assert 'xsh:sprintf("%e",13.123)="1.312300e+01"';

call x_assert 'xsh:sprintf("%s-%e-%s-%s","foo",13.123,"bar",/a)="foo-1.312300e+01-bar-abcb"';

$doc4 := create '<a><b>abc</b><c>efg</c></a>';

call x_assert '(xsh:map(/a/*,"string(text())")/self::xsh:string[1] = "abc")';

call x_assert '(xsh:map(/a/*,"string(text())")/self::xsh:string)[2] = "efg"';

call x_assert '(xsh:map(/a,"count(*)")/self::xsh:number[1] = 2)';

call x_assert '(xsh:map(/a,"*")/self::b)';

call x_assert '(xsh:map(/a,"*")/self::c)';

call x_assert '(xsh:same(xsh:map(/a,"*")/self::b,/a/b))';

call x_assert '(xsh:same(xsh:map(/a,"*")/self::c,/a/c))';

foreach //node() {
  call x_assert '(xsh:same(xsh:current(),.))';
}

foreach //b {
  call x_assert '//c[xsh:current()="abc"]';
}

local $pwd;
foreach //node() {
  pwd |> $pwd;
  count $pwd;
  perl { chomp $pwd; chomp $pwd };
  count $pwd;
  call x_assert 'xsh:path(.)="${pwd}"';
}

EOF

  plan tests => 4+@xsh_test;
}
END { ok(0) unless $loaded; }
use XML::XSH2 qw/&xsh &xsh_init &set_quiet &xsh_set_output/;
$loaded=1;
ok(1);

my $verbose=$ENV{HARNESS_VERBOSE};

($::RD_ERRORS,$::RD_WARN,$::RD_HINT)=(1,1,1);

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

#xsh_set_output(\*STDERR);
set_quiet(0);
xsh_init();

print STDERR "\n" if $verbose;
ok(1);

print STDERR "\n" if $verbose;
ok ( XML::XSH2::Functions::create_doc("scratch","scratch") );

print STDERR "\n" if $verbose;
ok ( XML::XSH2::Functions::set_local_xpath('/') );

foreach (@xsh_test) {
  print STDERR "\n\n[[ $_ ]]\n" if $verbose;
  eval { xsh($_) };
  print STDERR $@ if $@;
  ok( !$@ );
}

