# This file was automatically generated from src/xsh_grammar.xml on 
# Fri Nov  1 17:18:18 2002

package XML::XSH::Help;
use strict;
use vars qw($HELP %HELP);


$HELP=<<'END';
General notes:

  XSH acts as a command interpreter. Individual commands must be separated
  with a semicolon. Each command may be followed by a pipeline redirection
  to capture the command's output. In the interactive shell, backslash may
  be used at the end of line to indicate that the command follows on the
  next line.

  A pipeline redirections may be used either to feed the command's output
  to a unix command or to store it in a XSH string variable.

  In the first case, the syntax is `xsh-command | shell-command ;' where
  `xsh-command' is any XSH command and `shell-command' is any command (or
  code) recognized by the default shell interpreter of the operating system
  (i.e. on UNIX systems by `sh' or `csh', on Windows systems by `cmd').
  Brackets may be used to join more shell commands (may depend on which
  shell is used).

Example: Count any attributes that contain string foo in its name or value.

  xsh> ls //words/attribute() | grep foo | wc

  In order to store a command's output in a string variable, the pipeline
  redirection must take the form `xsh-command |> $variable' where
  `xsh-command' is any XSH command and `$variable' is any valid name for a
  string <variable>variable.

Example: Store the number of all words in a variable named count.

  xsh> count //words |> $count

  `<help> command' gives a list of all XSH commands.

  `<help> type' gives a list of all argument types.

  `<help>' followed by a command or type name gives more information on the
  particular command or argument type.

END

$HELP{'command'}=[<<'END'];
List of XSH commands

description:
	     assign, backups, call, cd, clone, close, copy, count, create,
	     debug, def, defs, dtd, enc, encoding, exec, exit, files, fold,
	     foreach, help, if, include, indent, insert, keep-blanks, lcd,
	     load-ext-dtd, local, locate, ls, map, move, nobackups,
	     nodebug, open, options, parser-completes-attributes,
	     parser-expands-entities, parser-expands-xinclude,
	     pedantic-parser, perl, print, process-xinclude, pwd,
	     query-encoding, quiet, recovering, remove, run-mode, save,
	     select, sort, switch-to-new-documents, test-mode, unfold,
	     unless, valid, validate, validation, variables, verbose,
	     version, while, xcopy, xinsert, xmove, xslt, xupdate

END


$HELP{'command-block'}=[<<'END'];
command-block argument type

description:
	     XSH command or a block of semicolon-separated commands
	     enclosed within curly brackets.

Example:     Count paragraphs in each chapter

             $i=0;
             foreach //chapter {
               $c=./para;
               $i=$i+1;
               print "$c paragraphs in chapter no.$i";
             }

END


$HELP{'type'}=[<<'END'];
List of command argument types

description:
	     command-block, enc-string, expression, filename, id, location,
	     node-type, perl-code, xpath

END


$HELP{'expression'}=[<<'END'];
expression argument type

description:
	     A string consisting of unquoted characters other than
	     whitespace or semicolon, single quote or double quote
	     characters or quoted characters of any kind. By quoting we
	     mean preceding a single character with a backslash or
	     enclosing a part of the string into single quotes '...' or
	     double quotes "...". Quoting characters are removed from the
	     string so they must be quoted themselves if they are a part of
	     the expression: \\, \' or " ' ", \" or ' " '. Unquoted
	     (sub)expressons or (sub)expressions quoted with double-quotes
	     are subject to variable, Perl, and XPath expansions.

	     Variable expansion replaces substrings of the form $id or
	     ${id} with the value of the variable named $id, unless the '$'
	     sign is quoted.

	     Perl expansion evaluates every substring enclosed in between
	     `${{{' and `}}}' as a Perl expresson (in very much the same
	     way as the <perl> command) and replaces the whole thing with
	     the resulting value.

	     XPath interpolation evaluates every substring enclosed in
	     between `${{' and `}}' as an XPath expression (in very much
	     the same way as the <count> command) and substitutes the whole
	     thing with the resul.

	     For convenience, another kind XPath interpolation is performed
	     on expressions. It replaces any substring occuring between
	     `${(' and `)}' with a literal result of XPath evaluation of
	     the string. This means, that if the evaluation results in a
	     node-list, the textual content of its first node is
	     substituted rather than the number of nodes in the node-list
	     (as with `${{ ... }}').

Example:
             echo foo "bar"                        # prints: foo bar
             echo foo"bar"                         # prints: foobar
             echo foo'"bar"'                       # prints: foo"bar"
             echo foo"'b\\a\"r'"                   # prints: foo'b\a"r'
             $a="bar"
             echo foo$a                            # prints: foobar
             echo foo\$a                           # prints: foo$a
             echo '$a'                             # prints: '$a'
             echo "'$a'"                           # prints: 'bar'
             echo "${{//middle-earth/creatures}}"  # prints: 10
             echo '${{//middle-earth/creatures}}'  # prints: ${{//middle-earth/creatures}}
             echo ${{//creature[1]/@name}}         # !!! prints: 1
             echo ${(//creature[1]/@name)}         # prints: Bilbo
             echo ${{{ join(",",split(//,$a)) }}}  # prints: b,a,r

END


$HELP{'enc-string'}=[<<'END'];
enc_string argument type

description:
	     An <expression> which interpolates to a valid encoding string,
	     e.g. to utf-8, utf-16, iso-8859-1, iso-8859-2, windows-1250
	     etc.

END


$HELP{'id'}=[<<'END'];
id argument type

description:
	     An identifier, that is, a string beginning with a letter or
	     underscore, and containing letters, underscores, and digits.

END


$HELP{'filename'}=[<<'END'];
Filename argument type

description:
	     An <expression> which interpolates to a valid file name.

END


$HELP{'xpath'}=[<<'END'];
Xpath argument type

description:
	     Any XPath expression as defined in W3C recommendation at
	     http://www.w3.org/TR/xpath optionally preceded with a document
	     identifier followed by colon. If no identifier is used, the
	     current document is used.

Example:     Open a document and count all sections containing a subsection
	     in it

             xsh scratch:/> open v = mydocument1.xml;
             xsh v:/> open k = mydocument2.xml;
             xsh k:/> count //section[subsection]; # searches k
             xsh k:/> count v://section[subsection]; # searches v

END


$HELP{'if'}=[<<'END'];
usage:       if <xpath>|<perl-code> <command>
             if <xpath>|<perl-code>
    <command-block> [ elsif <command-block> ]* [ else <command-block> ]
             
description:
	     Execute <command-block> if the given <xpath> or <perl-code>
	     expression evaluates to a non-emtpty node-list, true
	     boolean-value, non-zero number or non-empty literal. If the
	     first test fails, check all possibly following `elsif'
	     conditions and execute the corresponding <command-block> for
	     the first one of them which is true. If none of them succeeds,
	     execute the `else' <command-block> (if any).

Example:     Display node type

             def node_type %n {
               foreach (%n) {
                 if ( . = self::* ) { # XPath trick to check if . is an element
                   echo 'element';
                 } elsif ( . = ../@* ) { # XPath trick to check if . is an attribute
                   echo 'attribute';
                 } elsif ( . = ../processing-instruction() ) {
                   echo 'pi';
                 } elsif ( . = ../text() ) {
                   echo 'text';
                 } elsif ( . = ../comment() ) {
                   echo 'comment'
                 } else { # well, this should not happen, but anyway, ...
                   echo 'unknown-type';
                 }
               }
             }

END


$HELP{'unless'}=[<<'END'];
usage:       unless <xpath>|<perl-code>
    <command>
             unless <xpath>|<perl-code>
    <command-block> [ else <command-block> ]
             
description:
	     Like if but negating the result of the expression.

END


$HELP{'while'}=[<<'END'];
usage:       while <xpath>|<perl-code> <command-block>
             
description:
	     Execute <command-block> as long as the given <xpath> or
	     <perl-code> expression evaluates to a non-emtpty node-list,
	     true boolean-value, non-zero number or non-empty literal.

Example:     The commands have the same results

             xsh> while /table/row remove /table/row[1];
             xsh> remove /table/row;

END


$HELP{'foreach'}=[<<'END'];
usage:       foreach <xpath>|<perl-code> 
    <command>|<command-block>
             
aliases:     for

description:
	     If the first argument is an <xpath> expression, execute the
	     command-block for each node matching the expression making it
	     temporarily the current node, so that all relative XPath
	     expressions are evaluated in its context.

	     If the first argument is a <perl-code>, it is evaluated and
	     the resulting perl-list is iterated setting the variable $__
	     (note that there are two underscores!) to be each element of
	     the list in turn. It works much like perl's foreach, except
	     that the variable used consists of two underscores.

Example:     Move all employee elements in a company element into a staff
	     subelement of the same company

             xsh> foreach //company xmove ./employee into ./staff;

Example:     List content of all XML files in current directory

             xsh> foreach { glob('*.xml') } { open f=$__; list f:/; }

END

$HELP{'for'}=$HELP{'foreach'};

$HELP{'def'}=[<<'END'];
usage:       def <id> [$<id> | %<id>]* <command-block>
         or
  def <id> [$<id> | %<id>]*;
             
aliases:     define

description:
	     Define a new XSH subroutine named <id>. The subroutine may
	     require zero or more parameters of nodelist or string type.
	     These are declared as a whitespace-separated list of (so
	     called) parametric variables (of nodelist or string type). The
	     body of the subroutine is specified as a <command-block>.
	     Note, that all subroutine declarations are processed during
	     the parsing and not at run-time, so it does not matter where
	     the subroutine is defined.

	     The routine can be later invoked using the <call> command
	     followed by the routine name and parameters. Nodelist
	     parameters must be given as an XPath expressions, and are
	     evaluated just before the subroutine's body is executed.
	     String parameters must be given as (string) <expression>s.
	     Resulting node-lists/strings are stored into the parametric
	     variables before the body is executed. These variables are
	     local to the subroutine's call tree (see also the <local>
	     command). If there is a global variable using the same name as
	     some parametric variable, the original value of the global
	     variable is replaced with the value of the parametric variable
	     for the time of the subroutine's run-time.

	     Note that subroutine has to be declared before it is called
	     with <call>. If you cannot do so, e.g. if you want to call a
	     subroutine recursively, you have to pre-declare the subroutine
	     using a `def' with no <command-block>. There may be only one
	     full declaration (and possibly one pre-declaration) of a
	     subroutine for one <id> and the declaration and
	     pre-declaration has to define the same number of arguments and
	     their types must match.

Example:
             def l3 %v {
               ls %v 3; # list given nodes upto depth 3
             }
             call l3 //chapter;

Example:     Commenting and un-commenting pieces of document

             def comment
                 %n      # nodes to move to comments
                 $mark   # maybe some handy mark to recognize such comments
             {
               echo "MARK: $mark\n";
             
               foreach %n {
                 if ( . = ../@* ) {
                   echo "Warning: attribute nodes are not supported!";
                 } else {
                   echo "Commenting out:";
                   ls .;
                   local $node = "";
                   ls . |> $node;
                   add comment "$mark$node" replace .;
                 }
               }
             }
             
             def uncomment %n $mark {
               foreach %n {
                 if (. = ../comment()) { # is this node a comment node
                   local $string = substring-after(.,"$mark");
                   add chunk $string replace .;
                 } else {
                   echo "Warning: Ignoring non-comment node:";
                   ls . 0;
                 }
               }
             }
             
             
             # comment out all chapters with no paragraphs
             call comment //chapter[not(para)] "COMMENT-NOPARA";
             
             # uncomment all comments (may not always be valid!)
             $mark="COMMENT-NOPARA";
             call uncomment //comment()[starts-with(.,"$mark")] $mark;

END

$HELP{'define'}=$HELP{'def'};

$HELP{'assign'}=[<<'END'];
usage:       assign $<id>=<xpath>
             $<id>=<xpath>
             assign %<id>=<xpath>
             %<id>=<xpath>
             
description:
	     In the first two cases (where dollar sign appears) store the
	     result of evaluation of the <xpath> in a variable named $<id>.
	     In this case, <xpath> is evaluated in a simmilar way as in the
	     case of the <count>: if it results in a literal value this
	     value is used. If it results in a node-list, number of nodes
	     occuring in that node-list is used. Use the `string()' XPath
	     function to obtain a literal values in these cases.

Example:     String expressions

             xsh> $a=string(chapter/title)
             xsh> $b="hallo world"

Example:     Arithmetic expressions

             xsh> $a=5*100
             xsh> $a
             $a=500
             xsh> $a=(($a+5) div 10)
             xsh> $a
             $a=50.5

Example:     Counting nodes

             xsh> $a=//chapter
             xsh> $a
             $a=10
             xsh> %chapters=//chapter
             xsh> $a=%chapters
             xsh> $a
             $a=10

Example:     Some caveats of counting node-lists

             xsh> ls ./creature
             <creature race='hobbit' name="Bilbo"/>
             
             ## WRONG (@name results in a singleton node-list) !!!
             xsh> $name=@name
             xsh> $name
             $a=1
             
             ## CORRECT (use string() function)
             xsh> $name=string(@name)
             xsh> $name
             $a=Biblo

	     In the other two cases (where percent sign appears) find all
	     nodes matching the given <xpath> and store the resulting
	     node-list in the variable named %<id>. The variable may be
	     later used instead of an XPath expression.

END


$HELP{'local'}=[<<'END'];
usage:       local $<id> [ = <xpath>]
             local %<id> [ = <xpath>]
             
description:
	     This command acts in a very similar way as <assign> does,
	     except that the variable assignment is done temporarily and
	     lasts only for the rest of the nearest enclosing
	     <command-block>. At the end of the enclosing block or
	     subroutine the original value is restored. This command may
	     also be used without the assignment part and assignments may
	     be done later using the usual <assign> command.

	     Note, that the variable itself is not lexically is still
	     global in the sense that it is still visible to any subroutine
	     called subsequently from within the same block. A local just
	     gives temporary values to global (meaning package) variables.
	     Unlike Perl's `my' declarations it does not create a local
	     variable. This is known as dynamic scoping. Lexical scoping is
	     not implemented in XSH.

	     To sum up for Perl programmers: `local' in XSH works exactly
	     the same as `local' in Perl.

END


$HELP{'options'}=[<<'END'];
usage:       options
             
aliases:     flags

description:
	     List current values of all XSH flags and options (such as
	     validation flag or query-encoding).

Example:     Store current settings in your .xshrc

             xsh> options | cat > ~/.xshrc

END

$HELP{'flags'}=$HELP{'options'};

$HELP{'defs'}=[<<'END'];
usage:       defs
             
description:
	     List names and parametric variables for all defined XSH
	     routines.

END


$HELP{'include'}=[<<'END'];
usage:       include <filename>
             
aliases:     .

description:
	     Include a file named <filename> and execute all XSH commands
	     therein.

END

$HELP{'.'}=$HELP{'include'};

$HELP{'call'}=[<<'END'];
usage:       call <id> [<xpath> | <expression>]*
             
description:
	     Call an XSH subroutine named <id> previously created using
	     def. If the subroutine requires some paramters, these have to
	     be specified after the <id>. Node-list parameters are given by
	     means of <xpath> expressions. String parameters have to be
	     string <expression>s.

END


$HELP{'help'}=[<<'END'];
usage:       help <command>|argument-type
             
aliases:     ?

description:
	     Print help on a given command or argument type.

END

$HELP{'?'}=$HELP{'help'};

$HELP{'exec'}=[<<'END'];
usage:       exec <expression> [<expression> ...]
             
aliases:     system

description:
	     execute the system command(s) in <expression>s.

Example:     Count words in "hallo wold" string, then print name of your
	     machine's operating system.

             exec echo hallo world;                 # prints hallo world
             exec "echo hallo word | wc"; # counts words in hallo world
             exec uname;                            # prints operating system name

END

$HELP{'system'}=$HELP{'exec'};

$HELP{'xslt'}=[<<'END'];
usage:       xslt <id> <filename> <id> [(params|parameters) name=<expression> [name=<expression> ...]]
             
aliases:     transform xsl xsltproc process

description:
	     Load an XSLT stylesheet from a file and use it to transform
	     the document of the first <id> into a new document named <id>.
	     Parameters may be passed to a stylesheet after params keyword
	     in the form of a list of name=value pairs where name is the
	     parameter name and value is an <expression> interpolating to
	     its value. The resulting value is interpretted by XSLT
	     processor as an XPath expression so e.g. quotes surrounding a
	     XPath string have to be quoted themselves to preveserve them
	     during the XSH expression interpolation.

Example:
             xslt src stylesheet.xsl rslt params font="'14pt'" color="'red'"

END

$HELP{'transform'}=$HELP{'xslt'};
$HELP{'xsl'}=$HELP{'xslt'};
$HELP{'xsltproc'}=$HELP{'xslt'};
$HELP{'process'}=$HELP{'xslt'};

$HELP{'files'}=[<<'END'];
usage:       files
             
description:
	     List open files and their identifiers.

END


$HELP{'variables'}=[<<'END'];
usage:       variables
             
aliases:     vars var

description:
	     List all defined variables and their values.

END

$HELP{'vars'}=$HELP{'variables'};
$HELP{'var'}=$HELP{'variables'};

$HELP{'copy'}=[<<'END'];
usage:       copy <xpath> <location> <xpath>
             
aliases:     cp

description:
	     Copies nodes matching the first <xpath> to the destinations
	     determined by the <location> directive relative to the second
	     <xpath>. If more than one node matches the first <xpath> than
	     it is copied to the position relative to the corresponding
	     node matched by the second <xpath> according to the order in
	     which are nodes matched. Thus, the n'th node matching the
	     first <xpath> is copied to the location relative to the n'th
	     node matching the second <xpath>. The possible values for
	     <location> are: after, before, into, replace and cause copying
	     the source nodes after, before, into (as the last child-node).
	     the destination nodes. If replace <location> is used, the
	     source node is copied before the destination node and the
	     destination node is removed.

	     Some kind of type conversion is used when the types of the
	     source and destination nodes are not equal. Thus, text, cdata,
	     comment or processing instruction node data prepend, append or
	     replace value of a destination attribute when copied
	     before,after/into or instead (replace) an attribute, and vice
	     versa.

	     Attributes may be copied after, before or into some other
	     attribute to append, prepend or replace the destination
	     attribute value. They may also replace the destination
	     attribute completely (both its name and value).

	     To simply copy an attribute from one element to another,
	     simply copy the attribute node into the destination element.

	     Elements may be copied into other elements (which results in
	     appending the child-list of the destination element), or
	     before, after or instead (replace) other nodes of any type
	     except attributes.

Example:     Replace living-thing elements in the document b with the
	     coresponding creature elements of the document a.

             xsh> copy a://creature replace b://living-thing

END

$HELP{'cp'}=$HELP{'copy'};

$HELP{'xcopy'}=[<<'END'];
usage:       xcopy <xpath> <location> <xpath>
             
aliases:     xcp

description:
	     xcopy is similar to copy, but copies *all* nodes matching the
	     first <xpath> to *all* destinations determined by the
	     <location> directive relative to the second <xpath>. See copy
	     for detailed description of xcopy arguments.

Example:     Copy all middle-earth creatures within the document a into
	     every world of the document b.

             xsh> xcopy a:/middle-earth/creature into b://world

END

$HELP{'xcp'}=$HELP{'xcopy'};

$HELP{'lcd'}=[<<'END'];
usage:       lcd <expression>
             
aliases:     chdir

description:
	     Changes the filesystem working directory to <expression>, if
	     possible. If <expression> is omitted, changes to the directory
	     specified in HOME environment variable, if set; if not,
	     changes to the directory specified by LOGDIR environment
	     variable.

END

$HELP{'chdir'}=$HELP{'lcd'};

$HELP{'insert'}=[<<'END'];
usage:       insert <node-type> <expression> [namespace <expression>] <location><xpath>
             
aliases:     add

description:
	     Works just like xadd, except that the new node is attached
	     only the first node matched.

END

$HELP{'add'}=$HELP{'insert'};

$HELP{'xinsert'}=[<<'END'];
usage:       xinsert <node-type> <expression> [namespace <expression>] <location><xpath>
             
aliases:     xadd

description:
	     Use the <expression> to create a new node of a given
	     <node-type> in the <location> relative to the given <xpath>.

	     For element nodes, the format of the <expression> should look
	     like "<element-name att-name='attvalue' ...>". The `<' and `>'
	     characters are optional. If no attributes are used, the
	     expression may simply consist the element name. Note, that in
	     the first case, the quotes are required since the expression
	     contains spaces.

	     Attribute nodes use the following syntax: "att-name='attvalue'
	     [...]".

	     For the other types of nodes (text, cdata, comments) the
	     expression should contain the node's literal content. Again,
	     it is necessary to quote all whitespace and special characters
	     as in any expression argument.

	     The <location> argument should be one of: `after', `before',
	     `into', `replace', `append' or `prepend'. See documentation of
	     the <location> argument type for more detail.

	     The namespace <expression> is only valid for elements and
	     attributes and must evaluate to the namespace URI. In that
	     case, the element or attribute name must have a prefix. The
	     created node is associated with the given namespace.

Example:     Append a new Hobbit element to the list of middle-earth
	     creatures and name him Bilbo.

             xsh> xadd element "<creature race='hobbit' manner='good'>" \
                              into /middle-earth/creatures
             xsh> xadd attribute "name='Bilbo'" \
                              into /middle-earth/creatures/creature[@race='hobbit'][last()]

END

$HELP{'xadd'}=$HELP{'xinsert'};

$HELP{'node-type'}=[<<'END'];
Node-type argument type

description:
	     One of: element, attribute, text, cdata, comment, chunk and
	     (EXPERIMENTALLY!) entity_reference. A chunk is a character
	     string which forms a well-balanced peace of XML.

Example:
             add element hobbit into //middle-earth/creatures;
             add attribute 'name="Bilbo"' into //middle-earth/creatures/hobbit[last()];
             add chunk '<hobbit name="Frodo">A small guy from <place>Shire</place>.</hobbit>' 
               into //middle-earth/creatures;

END


$HELP{'location'}=[<<'END'];
Location argument type

description:
	     One of: `after', `before', `into', `append', `prepend',
	     `replace'.

	     NOTE: XSH 1.6 introduces two new values for location argument:
	     `append' and `prepend' and slighlty changes behavior of
	     `after' and `before'!

	     This argument is required by all commands that insert nodes to
	     a document in some way to a destination described by an XPath
	     expression. The meaning of the values listed above is supposed
	     be obvious in most cases, however the exact semantics for
	     location argument values depends on types of both the source
	     node and the target node.

	     `after/before' place the node right after/before the
	     destination node, except for when the destination node is a
	     document node or one of the source nodes is an attribute: If
	     the destination node is a document node, the source node is
	     attached to the end/beginning of the document (remember: there
	     is no "after/before a document"). If both the source and
	     destination nodes are attributes, then the source node is
	     simply attached to the element containing the destination node
	     (remember: there is no order on attribute nodes). If the
	     destination node is an attribute but the source node is of a
	     different type, then the textual content of the source node is
	     appended to the value of the destination attribute (i.e. in
	     this case after/before act just as append/prepend).

	     `append/prepend' appends/prepends the source node to the
	     destination node. If the destination node can contain other
	     nodes (i.e. it is an element or a document node) then the
	     entire source node is attached to it. In case of other
	     destination node types, the textual content of the source node
	     is appended/prepended to the content of the destination node.

	     `into' can also be used to place the source node to the end of
	     an element (in the same way as `append'), to attach an
	     attribute to an element, or, if the destination node is a text
	     node, cdata section, processing-instruction, attribute or
	     comment, to replace its textual content with the textual
	     content of the source node.

	     `replace' replaces the entire destination node with the source
	     node except for the case when the destination node is an
	     attribute and the source node is not. In such a case only the
	     value of the destination attribute is replaced with the
	     textual content of the source node. Note also that document
	     node can never be replaced.

END


$HELP{'move'}=[<<'END'];
usage:       move <xpath> <location> <xpath>
             
aliases:     mv

description:
	     `move' command acts exactly like <copy>, except that it
	     removes the source nodes after a succesfull copy. Remember
	     that the moved nodes are actually different nodes from the
	     original ones (which may not be obvious when moving nodes
	     within a single document into locations that do not require
	     type conversion). So, after the move, the original nodes do
	     not exist neither in the document itself nor any nodelist
	     variable.

	     See <copy> for more details on how the copies of the moved
	     nodes are created.

END

$HELP{'mv'}=$HELP{'move'};

$HELP{'xmove'}=[<<'END'];
usage:       xmove <xpath> <location> <xpath>
             
aliases:     xmv

description:
	     Like <xcopy>, except that `xmove' removes the source nodes
	     after a succesfull copy. Remember that the moved nodes are
	     actually different nodes from the original ones (which may not
	     be obvious when moving nodes within a single document into
	     locations that do not require type conversion). So, after the
	     move, the original nodes do not exist neither in the document
	     itself nor any nodelist variable.

	     See <xcopy> for more details on how the copies of the moved
	     nodes are created.

	     The following example demonstrates how `xcopy' can be used to
	     get rid of HTML `<font>' elements while preserving their
	     content. As an exercise, try to find out why simple `foreach
	     //font { xmove node() replace . }' would not work here.

Example:     Get rid of all <font> tags

             while //font[1] {
               foreach //font[1] {
                 xmove ./node() replace .;
               }
             }

END

$HELP{'xmv'}=$HELP{'xmove'};

$HELP{'clone'}=[<<'END'];
usage:       clone <id>=<id>
             
aliases:     dup

description:
	     Make a copy of the document identified by the <id> following
	     the equal sign assigning it the identifier of the first <id>.

END

$HELP{'dup'}=$HELP{'clone'};

$HELP{'ls'}=[<<'END'];
usage:       ls <xpath> [<expression>]
             
aliases:     list

description:
	     List the XML representation of all nodes matching <xpath>. The
	     optional <expression> argument may be provided to specify the
	     depth of XML tree listing. If negative, the tree will be
	     listed to unlimited depth. If the <expression> results in the
	     word `fold', elements marked with the <fold> command are
	     folded, i.e. listed only to a certain depth (this feature is
	     still EXPERIMENTAL!).

	     Unless in quiet mode, this command prints also number of nodes
	     matched on stderr.

	     If the <xpath> parameter is omitted, current context node is
	     listed to the depth of 1.

END

$HELP{'list'}=$HELP{'ls'};

$HELP{'count'}=[<<'END'];
usage:       count <xpath>
             
aliases:     print_value get

description:
	     Calculate the given <xpath> expression. If the result is a
	     node-list, return number of nodes in the node-list. If the
	     <xpath> results in a boolean, numeric or literal value, return
	     the value.

END

$HELP{'print_value'}=$HELP{'count'};
$HELP{'get'}=$HELP{'count'};

$HELP{'perl-code'}=[<<'END'];
Perl-code argument type

description:
	     A block of perl code enclosed in curly brackets or an
	     expression which interpolates to a perl expression. Variables
	     defined in XSH are visible in perl code as well. Since, in the
	     interactive mode, XSH redirects output to the terminal, you
	     cannot simply use perl print function for output if you want
	     to filter the result with a shell command. Instead use
	     predefined perl routine `echo ...' which is equivalent to
	     `print $::OUT ...'. The $::OUT perl-variable stores the
	     referenc to the terminal file handle.

Example:
             xsh> $i="foo";
             xsh> eval { echo "$i-bar\n"; } # prints foo-bar
             xsh> eval 'echo "\$i-bar\n";'  # exactly the same as above
             xsh> eval 'echo "$i-bar\n";'   # prints foo-bar too, but $i is
                 # interpolated by XSH. Perl actually evaluates echo "foo-bar\n";

END


$HELP{'perl'}=[<<'END'];
usage:       eval <perl-code>
             
aliases:     eval

description:
	     Evaluate the given perl expression and print the return value.

END

$HELP{'eval'}=$HELP{'perl'};

$HELP{'remove'}=[<<'END'];
usage:       remove <xpath>
             
aliases:     rm prune delete del

description:
	     Remove all nodes matching <xpath>.

Example:     Get rid of all evil creatures.

             xsh> del //creature[@manner='evil']

END

$HELP{'rm'}=$HELP{'remove'};
$HELP{'prune'}=$HELP{'remove'};
$HELP{'delete'}=$HELP{'remove'};
$HELP{'del'}=$HELP{'remove'};

$HELP{'print'}=[<<'END'];
usage:       print <expression> [<expression> ...]
             
aliases:     echo

description:
	     Interpolate and print given expression(s).

END

$HELP{'echo'}=$HELP{'print'};

$HELP{'sort'}=[<<'END'];
usage:       sort <command-block> <command-block> <perl-code> %<id>
             
description:
	     EXPERIMENTAL! This command is not yet guaranteed to remain in
	     the future releases.

	     This command may be used to sort the node-list stored in the
	     node-list variable <id>. On each comparizon, first the two
	     <command-block> are evaluated, each in a context of one of the
	     nodes to compare. These <command-block> are supposed to
	     prepair any variables needed for later order comparizon in the
	     <perl-code>. It is the <perl-code> that is responsible for
	     deciding which node comes first by returning either -1 (the
	     first node should come first), 0 (no precedence - e.g. the
	     nodes gave the same value for comparizon), or 1 (the second
	     node should come first).

Example:     Sort creatures by name

             xsh> local $a; local $b;
             xsh> local %c=/middle-earth[1]/creatures
             xsh> sort { $a=string(@name) }{ $b=string(@name) }{ $a cmp $b } %c
             xsh> xmove %c into /middle-earth[1]# replaces the creatures

END


$HELP{'map'}=[<<'END'];
usage:       map <perl-code> <xpath>
             
aliases:     sed

description:
	     Each of the nodes matching <xpath> is processed with the
	     <perl-code> in the following way: if the node is an element,
	     its name is processed, if it is an attribute, its value is
	     used, if it is a cdata section, text node, comment or
	     processing instruction, its data is used. The expression
	     should expect the data in the $_ variable and should use the
	     same variable to store the modified data.

Example:     Renames all hobbits to halflings

             xsh> map $_='halfling' //hobbit

Example:     Capitalises all hobbit names

             xsh> map { $_=ucfirst($_) } //hobbit/@name

Example:     Changes goblins to orcs in all hobbit tales.

             xsh> on s/goblin/orc/gi //hobbit/tale/text()

END

$HELP{'sed'}=$HELP{'map'};

$HELP{'close'}=[<<'END'];
usage:       close <id>
             
description:
	     Close the document identified by <id>, removing its parse-tree
	     from memory (note also that all nodes belonging to the
	     document are removed from all nodelists they appear in).

END


$HELP{'select'}=[<<'END'];
usage:       select <id>
             
description:
	     Make <id> the document identifier to be used in the next xpath
	     evaluation without identifier prefix.

Example:
             xsh> a=mydoc1.xml       # opens and selects a
             xsh> ls /               # lists a
             xsh> b=mydoc2.xml       # opens and selects b
             xsh> ls /               # lists b
             xsh> ls a:/             # lists and selects a
             xsh> select b           # does nothing except selecting b
             xsh> ls /               # lists b

END


$HELP{'open'}=[<<'END'];
usage:       [open [HTML|XML|DOCBOOK] [FILE|PIPE|STRING]] <id>=<expression>
             
description:
	     Load a new XML, HTML or SGML DOCBOOK document from the file,
	     URI, command output or string provided by the <expression>. In
	     XSH the document is given a symbolic name <id>. To identify
	     the documentin commands like close, save, validate, dtd or enc
	     simply use <id>. In commands which work on document nodes,
	     give <id>: prefix to XPath expressions to point the XPath to
	     the document.

Example:
             xsh> open x=mydoc.xml # open a document
             
             # quote file name if it contains whitespace
             xsh> open y="document with a long name with spaces.xml"
             
             # you may omit the word open when loading an XML file/URI.
             xsh> z=mybook.xml
             
             # use HTML or DOCBOOK keywords to load these types
             xsh> open HTML z=index.htm
             
             # use PIPE keyword to read output of a command
             xsh> open HTML PIPE z='wget -O - xsh.sourceforge.net/index.html'
             
             # use z: prefix to identify the document opened with the
             # previous comand in an XPath expression.
             xsh> ls z://chapter/title

END


$HELP{'create'}=[<<'END'];
usage:       create <id> <expression>
             
aliases:     new

description:
	     Create a new document using <expression> to form the root
	     element and associate it with the given identifier.

Example:
             xsh> create t1 root
             xsh> ls /
             <?xml version="1.0" encoding="utf-8"?>
             <root/>
             
             xsh> create t2 "<root id='r0'>Just a <b>test</b></root>"
             xsh> ls /
             <?xml version="1.0" encoding="utf-8"?>
             <root id='r0'>Just a <b>test</b></root>
             xsh> files
             scratch = new_document.xml
             t1 = new_document1.xml
             t2 = new_document2.xml

END

$HELP{'new'}=$HELP{'create'};

$HELP{'save'}=[<<'END'];
usage:       save [HTML|XML|XInclude]? [FILE|PIPE|STRING]? <id> <expression>? [encoding <enc-string>]
             
description:
	     Save the document identified by <id>. Using one of the `FILE',
	     `PIPE', `STRING' keywords the user may choose to save the
	     document to a file send it to a given command's input via a
	     pipe or simply return its content as a string. If none of the
	     keywords is used, it defaults to FILE. If saving to a PIPE,
	     the <expression> argument must provide the coresponding
	     command and all its parameters. If saving to a FILE, the
	     <expression> argument may provide a filename; if omitted, it
	     defaults to the original filename of the document. If saving
	     to a STRING, the <expression> argument is ignored and may
	     freely be omitted.

	     The output format is controlled using one of the XML, HTML,
	     XInclude keywords (see below). If the format keyword is
	     ommited, save it defaults to XML.

	     Note, that a document should be saved as HTML only if it
	     actually is a HTML document. Note also, that the optional
	     encoding parameter forces character conversion only; it is up
	     to the user to declare the document encoding in the
	     appropriate HTML <META> tag.

	     The XInclude keyword automatically implies XML format and can
	     be used to force XSH to save all already expanded XInclude
	     sections back to their original files while replacing them
	     with <xi:include> tags in the main XML file. Moreover, all
	     material included within <include> elements from the
	     `http://www.w3.org/2001/XInclude' namespace is saved to
	     separate files too according to the `href' attribute, leaving
	     only empty <include> element in the root file. This feature
	     may be used to split the document to new XInclude fragments.

	     The encoding keyword followed by a <enc-string> can be used to
	     convert the document from its original encoding to a different
	     encoding. In case of XML output, the <?xml?> declaration is
	     changed accordingly. The new encoding is also set as the
	     document encoding for the particular document.

Example:     Use save to preview a HTML document in Lynx

             save HTML PIPE mydoc 'lynx -stdin'

END


$HELP{'dtd'}=[<<'END'];
usage:       dtd [<id>]
             
description:
	     Print external or internal DTD for the given document. If no
	     document identifier is given, the current document is used.

END


$HELP{'enc'}=[<<'END'];
usage:       enc [<id>]
             
description:
	     Print the original document encoding string. If no document
	     identifier is given, the current document is used.

END


$HELP{'validate'}=[<<'END'];
usage:       validate [<id>]
             
description:
	     Try to validate the document identified with <id> according to
	     its DTD, report all validity errors. If no document identifier
	     is given, the current document is used.

END


$HELP{'valid'}=[<<'END'];
usage:       valid [<id>]
             
description:
	     Check and report the validity of a document. Prints "yes" if
	     the document is valid and "no" otherwise. If no document
	     identifier is given, the current document is used.

END


$HELP{'exit'}=[<<'END'];
usage:       exit [<expression>]
             
aliases:     quit

description:
	     Exit xsh immediately, optionally with the exit-code resulting
	     from the given expression.

	     WARNING: No files are saved on exit.

END

$HELP{'quit'}=$HELP{'exit'};

$HELP{'process-xinclude'}=[<<'END'];
usage:       process_xinclude [<id>]
             
aliases:     process_xinclude process-xincludes process_xincludes xinclude xincludes load_xincludes load-xincludes load_xinclude load-xinclude

description:
	     Process any xinclude tags in the document <id>.

END

$HELP{'process_xinclude'}=$HELP{'process-xinclude'};
$HELP{'process-xincludes'}=$HELP{'process-xinclude'};
$HELP{'process_xincludes'}=$HELP{'process-xinclude'};
$HELP{'xinclude'}=$HELP{'process-xinclude'};
$HELP{'xincludes'}=$HELP{'process-xinclude'};
$HELP{'load_xincludes'}=$HELP{'process-xinclude'};
$HELP{'load-xincludes'}=$HELP{'process-xinclude'};
$HELP{'load_xinclude'}=$HELP{'process-xinclude'};
$HELP{'load-xinclude'}=$HELP{'process-xinclude'};

$HELP{'cd'}=[<<'END'];
usage:       cd [<xpath>]
             
aliases:     chxpath

description:
	     Change current context node (and current document) to the
	     first node matching the given <xpath> argument.

END

$HELP{'chxpath'}=$HELP{'cd'};

$HELP{'pwd'}=[<<'END'];
usage:       pwd
             
description:
	     Print XPath leading to the current context node. This is
	     equivalent to `locate .'.

END


$HELP{'locate'}=[<<'END'];
usage:       locate <xpath>
             
description:
	     Print canonical XPaths leading to nodes matched by the <xpath>
	     given.

END


$HELP{'xupdate'}=[<<'END'];
usage:       xupdate <id> [<id>]
             
description:
	     Modify the current document or the document specified by the
	     second <id> argument according to XUpdate commands of the
	     first <id> document. XUpdate is a XML Update Language which
	     aims to be a language for updating XML documents.

	     XUpdate langauge is described in XUpdate Working Draft at
	     http://www.xmldb.org/xupdate/xupdate-wd.html.

	     XUpdate output can be generated for example by Python xmldiff
	     utility from http://www.logilab.org/xmldiff/. Unfortunatelly,
	     there are few bugs (or, as I tend to say In case of Python,
	     white-space problems) in their code, so its XUpdate output is
	     not always correct.

END


$HELP{'verbose'}=[<<'END'];
usage:       verbose
             
description:
	     Turn on verbose messages (default).

END


$HELP{'test-mode'}=[<<'END'];
usage:       test-mode
             
aliases:     test_mode

description:
	     Switch into test mode in which no commands are actually
	     executed and only command syntax is checked.

END

$HELP{'test_mode'}=$HELP{'test-mode'};

$HELP{'run-mode'}=[<<'END'];
usage:       run-mode
             
aliases:     run_mode

description:
	     Switch into normal XSH mode in which all commands are
	     executed.

END

$HELP{'run_mode'}=$HELP{'run-mode'};

$HELP{'debug'}=[<<'END'];
usage:       debug
             
description:
	     Turn on debugging messages.

END


$HELP{'nodebug'}=[<<'END'];
usage:       nodebug
             
description:
	     Turn off debugging messages.

END


$HELP{'version'}=[<<'END'];
usage:       version
             
description:
	     Prints program version as well as versions of
	     XML::XSH::Functions, XML::LibXML, and XML::LibXSLT modules
	     used.

END


$HELP{'validation'}=[<<'END'];
usage:       validation <expression>
             
description:
	     Turn on validation during the parse process if the
	     <expression> is non-zero or off otherwise. In XSH version 1.6
	     and later, defaults to off.

END


$HELP{'recovering'}=[<<'END'];
usage:       recovering <expression>
             
description:
	     Turn on recovering parser mode if the <expression> is non-zero
	     or off otherwise. Defaults to off. Note, that the in the
	     recovering mode, validation is not performed by the parser
	     even if the validation flag is on and that recovering mode
	     flag only influences parsing of XML documents (not HTML).

	     The recover mode helps to efficiently recover documents that
	     are almost well-formed. This for example includes documents
	     without a close tag for the document element (or any other
	     element inside the document).

END


$HELP{'parser-expands-entities'}=[<<'END'];
usage:       parser_expands_entities <expression>
             
aliases:     parser_expands_entities

description:
	     Turn on the entity expansion during the parse process if the
	     <expression> is non-zero on or off otherwise. If entity
	     expansion is off, any external parsed entities in the document
	     are left as entities. Defaults to on.

END

$HELP{'parser_expands_entities'}=$HELP{'parser-expands-entities'};

$HELP{'keep-blanks'}=[<<'END'];
usage:       keep_blanks <expression>
             
aliases:     keep_blanks

description:
	     Allows you to turn off XML::LibXML's default behaviour of
	     maintaining whitespace in the document. Non-zero expression
	     forces the XML parser to preserve all whitespace.

END

$HELP{'keep_blanks'}=$HELP{'keep-blanks'};

$HELP{'pedantic-parser'}=[<<'END'];
usage:       pedantic_parser <expression>
             
aliases:     pedantic_parser

description:
	     If you wish, you can make XML::LibXML more pedantic by passing
	     a non-zero <expression> to this command.

END

$HELP{'pedantic_parser'}=$HELP{'pedantic-parser'};

$HELP{'parser-completes-attributes'}=[<<'END'];
usage:       parser-completes-attributes <expression>
             
aliases:     complete_attributes complete-attributes parser_completes_attributes

description:
	     If the expression is non-zero, this command allows XML parser
	     to complete the elements attributes lists with the ones
	     defaulted from the DTDs. By default, this option is enabled.

END

$HELP{'complete_attributes'}=$HELP{'parser-completes-attributes'};
$HELP{'complete-attributes'}=$HELP{'parser-completes-attributes'};
$HELP{'parser_completes_attributes'}=$HELP{'parser-completes-attributes'};

$HELP{'indent'}=[<<'END'];
usage:       indent <expression>
             
description:
	     If the value of <expression> is 1, format the XML output while
	     saving a document by adding some nice ignorable whitespace. If
	     the value is 2 (or higher), XSH will act as in case of 1, plus
	     it will add a leading and a trailing linebreak to each text
	     node.

	     Note, that since the underlying C library (libxml2) uses a
	     hardcoded indentation of 2 space characters per indentation
	     level, the amount of whitespace used for indentation can not
	     be altered on runtime.

END


$HELP{'parser-expands-xinclude'}=[<<'END'];
usage:       parser_expands_xinclude <expression>
             
aliases:     parser_expands_xinclude

description:
	     If the <expression> is non-zero, the parser is allowed to
	     expand XIinclude tags imidiatly while parsing the document.

END

$HELP{'parser_expands_xinclude'}=$HELP{'parser-expands-xinclude'};

$HELP{'load-ext-dtd'}=[<<'END'];
usage:       load_ext_dtd <expression>
             
aliases:     load_ext_dtd

description:
	     If the expression is non-zero, XML parser loads external DTD
	     subsets while parsing. By default, this option is enabled.

END

$HELP{'load_ext_dtd'}=$HELP{'load-ext-dtd'};

$HELP{'encoding'}=[<<'END'];
usage:       encoding <enc-string>
             
description:
	     Set the default output character encoding.

END


$HELP{'query-encoding'}=[<<'END'];
usage:       query-encoding <enc-string>
             
aliases:     query_encoding

description:
	     Set the default query character encoding.

END

$HELP{'query_encoding'}=$HELP{'query-encoding'};

$HELP{'quiet'}=[<<'END'];
usage:       quiet
             
description:
	     Turn off verbose messages.

END


$HELP{'switch-to-new-documents'}=[<<'END'];
usage:       switch-to-new-documents <expression>
             
aliases:     switch_to_new_documents

description:
	     If non-zero, XSH changes current node to the document node of
	     a newly open/created files every time a new document is opened
	     or created with <open> or <create>. Default value for this
	     option is 1.

END

$HELP{'switch_to_new_documents'}=$HELP{'switch-to-new-documents'};

$HELP{'backups'}=[<<'END'];
usage:       backups
             
description:
	     Enable creating backup files on save (default).

END


$HELP{'nobackups'}=[<<'END'];
usage:       nobackups
             
description:
	     Disable creating backup files on save.

END


$HELP{'fold'}=[<<'END'];
usage:       fold <xpath> [<expression>]
             
description:
	     This feature is still EXPERIMENTAL! Fold command may be used
	     to mark elements matching the <xpath> with a `xsh:fold'
	     attribute from the `http://xsh.sourceforge.net/xsh/'
	     namespace. When listing the DOM tree using `<ls> <xpath>
	     fold', elements marked in this way are folded to the depth
	     given by the <expression> (default depth is 0 = fold
	     immediately).

Example:
             xsh> fold //chapter 1
             xsh> ls //chapter[1] fold
             <chapter id="intro" xsh:fold="1">
               <title>...</title>
               <para>...</para>
               <para>...</para>
             </chapter>

END


$HELP{'unfold'}=[<<'END'];
usage:       unfold <xpath>
             
description:
	     This feature is still EXPERIMENTAL! Unfold command removes
	     `xsh:fold' attributes from all elements matching given <xpath>
	     created by previous usage of <fold>. Be aware, that
	     `xmlns:xsh' namespace declaration may still be present in the
	     document even when all elements are unfolded.

END



1;
__END__

