#!xsh
# -*- cperl -*-

$db_stylesheet = "/usr/share/xml/docbook/stylesheet/nwalsh/1.64.1/html/docbook.xsl";

if ("$xsh_grammar_file" = "") $xsh_grammar_file="src/xsh_grammar.xml";
if ("$db_stylesheet" = "") {
  # weired things happen in XML::LibXML/LibXSLT with new stylesheets!
#  $db_stylesheet="http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl";

  perl { ($db_stylesheet)=split(/\n/,`locate html/docbook.xsl`); };
  echo "Using DocBook XML stylesheet: $db_stylesheet"
}
if ("$db_stylesheet" = "") {
  echo "Cannot find docbook.xsl stylesheets! Exiting."
  exit 1;
}
if ("$html_stylesheet"="") $html_stylesheet="style.css";

quiet;
load-ext-dtd 1;
validation 1;
parser-completes-attributes 1;
xpath-extensions;

open X = $xsh_grammar_file;

validation 0;
indent 1;

def transform_section %s {
  map { s/^[ \t]+//; s/\n[ \t]+/\n/g; } %s//code/descendant::text();
  foreach %s//code/descendant::tab {
    insert text ${(times(@count,'  '))} replace .;
  }
  rename { $_='programlisting' } %s//code;
  local %sl;
  foreach %s/descendant::typeref {
    insert element "simplelist type='inline'" before . result %sl;
    foreach split("\\s",@types) {
      foreach X:(/recdescent-xml/rules/rule[@type=current()]) {
	local $c;
	if (@id) {
	  $c=concat("<member><xref linkend='",@id,"'/></member>");
	} else {
	  $c=concat("<member>",@name,"</member>");
	}
	insert chunk $c into %sl;
      }
    }
    rm .;
  }
  foreach %s//xref {
    local $c;
    local $l=string(@linkend);
    foreach X:(id("${l}")) {
      $c=string(if(name()="section",title,if(@name,@name,@id)));
    }
    add chunk "<ulink url='s_${l}.html'>${c}</ulink>" replace .;
  };
  foreach %s//link {
    map { $_='ulink' } .;
    add attribute url=${{string(@linkend)}} replace @linkend;
    map { $_="s_".$_.".html" } @url;
  }
#  clone SS=S;
#  xslt SS $db_stylesheet H params html.stylesheet="'$html_stylesheet'";
  xslt S $db_stylesheet H params html.stylesheet="'$html_stylesheet'";
#  close SS;
#  clone H=H;
  xadd attribute target=_self into H://*[name()='a'];
  # move content of <a name="">..</a> out, so that it does not behave
  # as a link in browsers
  foreach H://*[name()='a' and not(@href)] {
    xmove ./node() after .;
  }
  echo "saving";
  for %s/@id {
    echo "saving doc/frames/s_${{string(.)}}.html";
    save_HTML H "doc/frames/s_${{string(.)}}.html";
    echo "saving doc/frames/s_${{string(.)}}.xml";
    saveas S "doc/frames/s_${{string(.)}}.xml";
  }
  close H;
}

echo 'index';
perl {
$toc_template=<<"EOF";
<html>
  <head>
    <title>Table of contents</title>
    <link href='$html_stylesheet' rel='stylesheet'/>
  </head>
  <body>
    <h2>XSH Reference</h2>
    <font color='#000090' size='-2'>
      <a href='t_syntax.html' target='mainIndex'>Syntax</a><br/>
      <a href='t_command.html' target='mainIndex'>Commands</a><br/>
      <a href='t_argtype.html' target='mainIndex'>Argument Types</a><br/>
      <a href='t_function.html' target='mainIndex'>XPath Functions</a><br/>
    </font>
    <hr/>
    <small></small>
  </body>
</html>
EOF
};
new I <<"EOF";
<html>
  <head>
    <title>XSH Reference</title>
    <link href='$html_stylesheet' rel='stylesheet'/>
  </head>
  <frameset cols='250,*'>
     <frame name='mainIndex' src='t_syntax.html'/>
     <frame name='mainWindow' src='s_intro.html'/>
     <noframes>
       <body>
         <p>XSH Reference - XSH is an XML Editing Shell</p>
         <small>Your browser must support frames to display this
         page correctly!</small>
       </body>
     </noframes>
  </frameset>
</html>
EOF

save_HTML I 'doc/frames/index.html';
close I;

echo 'sections';
new S "<section id='intro'><title>Getting Started</title></section>";
%section=S://section;
xcopy X:/recdescent-xml/doc/description/node() into %section;
call transform_section %section;
close S;

# SYNTAX TOC
new T $toc_template;
for T:(/html/body/font/a[contains(@href,'syntax')]) {
  echo 'sec';
  add chunk "<u><b/></u>" before .;
  move . into preceding-sibling::u/b;
}
add chunk "<a href='s_intro.html' target='mainWindow'>Getting started</a><br/>"
  into T:/html/body/small;

foreach X:/recdescent-xml/doc/section {
  $id=string(@id);
  echo $id;
  add chunk "<a href='s_${id}.html' target='mainWindow'>${{string(title)}}</a><br/>"
    into T:/html/body/small;
  for (.) { # avoid selecting S:/
    new S "<section id='${id}'/>";
    %section=S:section;
  }
  xcopy ./node() into %section;

  %rules=X:(/recdescent-xml/rules/rule[documentation[id(@sections)[@id='$id']]]);
  if %rules
    add chunk "<simplesect>
                 <title>Related Topics</title>
                 <variablelist/>
               </simplesect>" into %section;
  sort (@name|@id) { $a cmp $b } %rules;
  foreach %rules {
    add chunk "<varlistentry>
      <term><xref linkend='${{string(./@id)}}'/></term>
      <listitem></listitem>
    </varlistentry>" into %section/simplesect[last()]/variablelist;
    xcopy ./documentation/shortdesc/node()
      into %section/simplesect[last()]/variablelist/varlistentry[last()]/listitem;
  }
  call transform_section %section;
}

save_HTML T "doc/frames/t_syntax.html";
close T;

# COMMANDS, TYPES AND FUNCTIONS
foreach { qw(command type function list) } {
  echo $__;
  new T $toc_template;

  for T:(/html/body/font/a[contains(@href,'$__')]) {
    add chunk "<u><b/></u>" before .;
    move . into preceding-sibling::u/b;
  }
  if ('$__'='type') $__='argtype';
  %rules=X:(//rule[@type='$__']);
  sort (documentation/title|@name|@id) { lc($a) cmp lc($b) } %rules;
  foreach %rules {
    $ref=string(@id);
    echo "rule: $ref";
    new S "<section id='$ref'/>";
    cd X:id('$ref');
    %section=S:section;

    # TITLE
    if (./documentation/title) {
      xcopy ./documentation/title into %section;
    } else {
      add chunk "<title>${{string(@name)}}</title>" into %section;
    }
    map { s/\s+argument\s+type//i; $_=lcfirst if lc(lcfirst($_)) eq lcfirst} %section/title/text();
    for %section/title {
      add chunk "<a href='s_${ref}.html' target='mainWindow'>${{string(.)}}</a><br/>"
	into T:/html/body/small;
    }
    if ('${__}'='argtype') { $t = 'argument type' } else { $t='${__}' }
    insert text " $t" into %section/title;
    #USAGE
    if (./documentation/usage) {
      add chunk "<simplesect><title>Usage</title></simplesect>" into %section;
      foreach (./documentation/usage) {
	add element para into %section/simplesect[last()];
      }
      copy ./documentation/usage into %section/simplesect[last()]/para;
      map { $_='literal' } %section/simplesect[last()]/para/usage;
    }

    #ALIASES
    if (./aliases/alias) {
      add chunk "<simplesect><title>Aliases</title><para><literal> </literal></para></simplesect>" into %section;
      foreach (./aliases/alias) {
	copy ./@name append %section/simplesect[last()]/para/literal/text()[last()];
	if (following-sibling::alias) {
	  add text ", " append %section/simplesect[last()]/para/literal/text()[last()];;
	}
      }
    }

    #DESCRIPTION
    if (./documentation/description) {
      add chunk "<simplesect><title>Description</title></simplesect>" into %section;
      xcopy ./documentation/description/node() into %section/simplesect[last()];
    }

    #SEE ALSO
    if (./documentation/see-also/ruleref) {
      add chunk "<simplesect><title>See Also</title><para/></simplesect>" into %section;
      foreach (./documentation/see-also/ruleref) {
	add element "<xref linkend='${{string(@ref)}}'/>" into %section/simplesect[last()]/para;
	if (following-sibling::ruleref) {
	  add text ", " into %section/simplesect[last()]/para;
	}
      }
    }
    #SECTIONS
    if (./documentation/@sections) {
      add chunk "<simplesect><title>Sections</title><para/></simplesect>" into %section;
      $s=string(./documentation/@sections);
      foreach { split /\s+/, $s } {
	add chunk "<xref linkend='$__'/>"
	  into %section/simplesect[last()]/para;
      };
      foreach %section/simplesect[last()]/para/xref {
	if (following-sibling::xref) {
	  add text ", " after . ;
	}
      }
    }
    call transform_section %section;
    close S;
  }
  echo "writing doc/frames/t_${__}.html";
  save_HTML T "doc/frames/t_${__}.html";
  close T;
};
