#!xsh
# -*- cperl -*-

if ("$xsh_grammar_file" = "") $xsh_grammar_file="src/xsh_grammar.xml";

quiet;
load-ext-dtd 1;
validation 1;
parser-completes-attributes 1;

open x = $xsh_grammar_file;

load-ext-dtd 0;
validation 0;

create d <<EOF;
<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN" 
  "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd">
<article>
  <title>XSH Reference</title>
  <section id="intro">
    <title>XSH Language</title>
  </section>
  <section id="command">
    <title>Command Reference</title>
  </section>
  <section id="type">
    <title>Type Reference</title>
  </section>
  <section id="function">
    <title>XPath Extension Function Reference</title>
  </section>
</article>
EOF

xcopy x:/recdescent-xml/doc/description/node() into d:/article/section[@id='intro'];
xcopy x:/recdescent-xml/doc/section into d:/article/section[@id='intro'];


foreach d:/article/section[@id='intro']/section {
  local $id=string(@id);
  local %rules=x:/recdescent-xml/rules/rule[documentation[id(@sections)[@id='$id']]];
  echo section: $id, rules: ${{%rules}};

  if %rules[@type='command' or @type='argtype' or @type='function']
    add chunk <<"EOF" append .;
<section>
  <title>Related topics</title>
  <para>
    <variablelist/>
  </para>
 </section>
EOF
  local %varlist=./section[last()]/para/variablelist;
  local $a $b;
  sort (@name|@id) { $a cmp $b } %rules;
  foreach %rules {
    add chunk <<"EOF" into %varlist;
    <varlistentry>
      <term><xref linkend='${{string(./@id)}}'/></term>
      <listitem><para/></listitem>
    </varlistentry>
EOF
    xcopy ./documentation/shortdesc/node() into %varlist/varlistentry[last()]/listitem/para;
  }
}

foreach { qw(command type function) } {
  print "FILLING: ${__}"; print "";
  local %sec=d:/article/section[@id='${__}'];
  if ('$__'='type') $__='argtype';
  local %type=x:(//rule[@type='$__']);
  sort (@name|documentation/title)[1] { $a cmp $b } %type;
  foreach %type {
    local $ref=string(@id);

    cd x:id('$ref');
    # TITLE
    add element "section id='$ref'" into %sec;

    local %section=%sec/section[last()];

    if (./documentation/title) {
      xcopy ./documentation/title into %section;
    } else {
      add chunk "<title>${{string(@name)}}</title>" into %section;
    }
    map { s/\s+argument\s+type//i; $_=lcfirst } %section/title/text();


    #USAGE
    if (./documentation/usage) {
      local %us;
      add chunk "<simplesect><title>Usage</title><para></para></simplesect>"
	into %section result %us;
      copy ./documentation/usage into %us/para;
      rename { $_='literal' } %us/para/usage;
    }

    #ALIASES
    if (./aliases/alias) {
      local %us;
      add chunk <<CHUNK into %section result %us;
 <simplesect>
   <title>Aliases</title>
   <para><literal> </literal></para>
 </simplesect>
CHUNK
      foreach (./aliases/alias) {
	copy ./@name append %us/para/literal/text()[last()];
	if (following-sibling::alias) {
	  add text ", " append %us/para/literal/text()[last()];
	}
      }
    }

    #DESCRIPTION
    if (./documentation/description) {
      local %us;
      add chunk "<simplesect><title>Description</title></simplesect>"
	into %section result %us;
      xcopy ./documentation/description/node() into %us;
    }

    #SEE ALSO
    if (./documentation/see-also/ruleref) {
      local %us;
      add chunk "<simplesect><title>See Also</title><para/></simplesect>"
	into %section result %us;
      foreach (./documentation/see-also/ruleref) {
	add element "<xref linkend='${{string(@ref)}}'/>"
	  into %us/para;
	if (following-sibling::ruleref) add text ", " into %us/para;
      }
    }
  }
};

map { s/^[ \t]+//; s/\n[ \t]+/\n/g; } d://code/descendant::text();
foreach d://tab {
  insert text ${{{ "  " x literal('@count') }}} replace .;
}
map { $_='programlisting' } d://code;

foreach d://xref {
  map { $_='link' } .;
  local $linkend=string(@linkend);
  insert text "${( x:(xsh:if(id('${linkend}')/@name,id('${linkend}')/@name,
			    id('${linkend}')/@id)) )}" into .;
};

foreach d://variablelist {
  local $termlength=1;
  foreach varlistentry/term {
    local $length=0;
    map { $length+=length($_) } descendant::text();
    perl { $termlength = $termlength < $length ? $length : $termlength };
  }
  insert attribute termlength=$termlength into .;
}

indent 1;
rename {$_='informalexample'} //example[not(title)]; # for validity sake
for { 1..5 } {
  rename {$_='sect'.$__} //section[not(ancestor::section)]; # for validity sake
}
saveas d 'doc/xsh_reference.xml';
