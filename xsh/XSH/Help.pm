package XSH::Help;
use strict;
use vars qw($HELP %HELP);

$HELP=<<'EOH';

General notes:
 - More than one command may be used on one line. In that case
   the commands must be separated by semicolon which has to be
   preceded by white-space.
 - Any command or set of commands may be followed by a pipeline filter
   (like in a Unix shell) to process its output, so for example

     xsh> list //words/attribute() | grep foo | wc

   counts any attributes that contain string foo in its name or value.
 - Many commands have aliases. See help <command> for a list.
 - In the interactive shell use slash in the end of line to indicate
   that the command follows on next line.

Argument types:
  id, expression, xpath, command-block, perl-code,
  node-type, location, encoding, filename, parameter-list

Available commands:

  add, assign, call, cd, clone, close, copy, count, create, debug,
  def, dtd, enc, encoding, eval, exec, exit, files, foreach, help, if,
  include, list, map, move, nodebug, open, print, query-encoding,
  quiet, remove, run-mode, save, saveas, test-mode, unless, valid,
  validate, variables, verbose, while, xadd, xcopy, xmove, xslt

Type help <command|type> to get more information on a given command or
argument type.

EOH


%HELP= ('help' => <<'H1',

usage:       help command|type

aliases:     help, ?

description: Print help on a given command or argument type.

H1

'id' => <<'H1',

id argument type

description: an identifier, that is, a string beginning with a letter or
             underscore, and containing letters, underscores, and digits.

H1
'parameter-list' => <<'H1',

parameter-list argument type

description: a non-empty whitespace separated list of name = value pairs
             where name is a string of non-whitespace characters containing
             no equal sign character and value is any expression. Any whitespace
             surrounding the equal sign between name and value is ignored.

H1
'expression' => <<'H1',

filename argument type

description: an expression which interpolates to a valid file name.

H1
'expression' => <<'H1',

expression argument type

description: a string consisting of unquoted characters other than
             whitespace or semicolon, single quote or double quote
             characters or quoted characters of any kind. By quoting
             we mean preceding a single character with a backslash or
             enclosing a part of the string into single quotes '...'
             or double quotes "...". Quoting characters are removed
             from the string so they must be quoted themselves if they
             are a part of the expression: \\, \' or "'", \" or '"'.

             Variable interpolation is performed on expressions, which
             means that any substrings of the forms $id or ${id} where
             $ is unquoted and id is an identifier are substituted
             with the value of the variable named $id.

             XPath interpolation is performed on expressions, which
             means that any substring enclosed in between ${{ and }}
             is evaluated in the same way as in the count command and
             the result of the evaluation is substituted in its place.

examples: print 'say "cheese"'               # prints: say "cheese"
          print \\\;\$\'\"                   # prints: \;$'"
          print ";";                         # prints: ;
          print chapters:\ ${{//chapter}}    # prints number of chapters
          print 'chapters: ${{//chapter}}'   # same as above
H1

'xpath' => <<'H1',

xpath argument type

description: any XPath expression as defined in W3C recommendation at
             http://www.w3.org/TR/xpath optionaly preceded with
             a document identifier followed by colon. If no identifier
             is used, the most recently adressed or opened document is
             used.

example:
             open v = mydocument.xml;
             count v://chapter[subsection];  # count all chapters containing
                                             # a subsection
H1
'command-block' => <<'H1',

command-block argument type

description: XSH command or a block of semicolon-separated
             commands enclosed within curly brackets.

example:     $i=0;                # count paragraphs in each chapter
             foreach //chapter {
               $c=./para;
               $i=$i+1;
               print "$c paragraphs in chapter no.$i";
             }
H1
'perl-code' => <<'H1',

perl-code argument type

description: a block of perl code enclosed in curly brackets or an
             expression which interpolates to a perl
             expression. Variables defined in XSH are visible in perl
             code as well. Since XSH redirects output to the terminal,
             you cannot simply use perl print function for output if
             you want to filter the result with a shell
             command. Instead use predefined perl routine `echo ...'
             which is equivalent to `print $::OUT ...'. The $::OUT
             perl-variable stores the referenc to the terminal file
             handle.

examples:    $i="foo";

             eval { echo "$i-bar\n"; } # prints foo-bar

             eval 'echo "\$i-bar\n";'  # exactly the same as above

             eval 'echo "$i-bar\n";'   # prints foo-bar too, but $i is
                                       # interpolated by XSH, so perl
                                       # actually evaluates
                                       #  echo "foo-bar\n";

H1
'node-type' => <<'H1',

node-type argument type

description: one of: element, attribute, text, cdata, comment.

examples:  add element hobbit into //middle-earth/creatures;
           add attribute 'name="Bilbo"' into //middle-earth/creatures/hobbit[last()];

H1
'location' => <<'H1',

location argument type

description: one of: after, before, into, replace.

             Aliases `to', `as child' and `as child of' may be used
             instead of `into'. Aliases `instead' and `instead of' may
             be used instead of `replace'.

H1
'encoding' => <<'H1',

encoding argument type

description: an expression which interpolates to a valid encoding
             string, e.g. to utf-8, utf-16, iso-8859-1, iso-8859-2,
             windows-1250 etc.
H1

'exit' => <<'H1',
usage:       exit [<expression>]

aliases:     exit, quit

description: Exit xsh immediately, optionaly with the exit-code
             resulting from the given expression.

warning:     No files are saved on exit.

H1

'foreach' => <<'H1',
usage:       foreach <xpath> <command-block>

description: Execute the command-block for each of the nodes matching
             the given XPath expression so that all relative XPath
             expressions of the command relate to the selected node.

example:     xsh> foreach //company xmove ./employee into ./staff;

             # moves all employee elements in a company element into a
             # staff subelement of the same company

H1

'while' => <<'H1',
usage:       while <xpath> <command-block>

description: Execute <command-block> as long as the given <xpath>
             expression evaluates to a non-emtpty node-list, true
             boolean-value, non-zero number or non-empty literal.

example:     the following commands have the same results:

             xsh> while /table/row remove /table/row[1];
             xsh> remove /table/row;

H1

'unless' => <<'H1',
usage:       unless <xpath> <command-block>

aliases:     "if !"

description: Like if but negating the result of the <xpath> expression.

see also:    if

H1

'if' => <<'H1',
usage:       if <xpath> <command-block>

description: Execute <command-block> if the given <xpath> expression
             evaluates to a non-emtpty node-list, true boolean-value,
             non-zero number or non-empty literal.

H1

'validate' => <<'H1',
usage:       validate [<id>]

description: Try to validate the document identified with <id>
             according to its DTD, report all validity errors.  If no
             document identifier is given, the document last used in
             an Xpath expression or a command is used.

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
'enc' => <<'H1',
usage:       enc [<id>]

description: Print the original document encoding string.
             If no document identifier is given, the document
             last used in an Xpath expression or a command
             is used.

H1
'count' => <<'H1',
usage:       count <xpath>

aliases:     xpath

description: Calculate the given <xpath> expression. If the result
             is a node-list, return number of nodes in the node-list.
             If the <xpath> results in a boolean, numeric or literal value,
             return the value.

WARNING:     Evaluation of <xpath> is done by XML::LibXML library. If the
             expression is not a valid XPath expression, the library may
             (but also may not) cause segmentation fault which results in
             loss of any unsaved xsh data. I've sent a patch to the authors
             of XML::LibXML and they approved it. Let's see if it appears
             in the next version and when that will be released.

see also:    list, eval

H1
'eval' => <<'H1',
usage:       eval <perl-code>

aliases:     perl

description: Evaluate the given perl expression and print the return value.

see also:    count

H1
'list' => <<'H1',
usage:       list <xpath>

aliases:     ls

description: List the XML representation of all elements matching <xpath>.
             Unless in quiet mode, print number of nodes matched on stderr.

see also:    count

H1
'transform' => <<'H1',
usage:       transform <id> <filename> <id> [params <parameter-list>]

aliases:     xslt, xsl, xsltproc, process

description: Load an XSLT stylesheet from a file and use it to
             transform the document of the first <id> into a new
             document named <id>. Parameters may be passed to a
             stylesheet after params keyword in the form of a
             list of name=value pairs where name is the parameter
             name and value is an expression interpolating to
             its value.

H1
'on' => <<'H1',
usage:       map <perl-code> <xpath>

aliases:     sed

description: Each of the nodes matching <xpath> is processed with the
             <perl-code> in the following way: if the node is an
             element, its name is processed, if it is an attribute,
             its value is used, if it is a cdata section, text node,
             comment or processing instruction, its data is used.  The
             expression should expect the data in the $_ variable and
             should use the same variable to store the modified data.

examples:    xsh> map $_='halfling' //hobbit
             renames all hobbits to halflings

             xsh> map { $_=ucfirst($_) } //hobbit/@name
             capitalises all hobbit names

             xsh> on s/goblin/orc/gi //hobbit/tale/text()
             changes goblins to orcs in all hobbit tales.

H1
'remove' => <<'H1',
usage:       remove <xpath>

aliases:     delete, del, rm, prune

description: Remove all nodes matching <xpath>.

example:     xsh> del //creature[@manner='evil']
             get rid of all evil creatures

H1
'xadd' => <<'H1',
usage:       xadd <node-type> <expression> <location> <xpath>

aliases:     xinsert

description: Use the <expression> to create a new node of a given
             <node-type> in the <location> relative to the given
             <xpath>.

             For element nodes, the format of the <expression> should
             look like "<element-name att-name='attvalue' ...>".
             If no attributes are used, the expression may simply
             consist the element name. Note, that in the first case,
             the quotes are required since the expression contains
             spaces.

             Attribute nodes use the following syntax:
             "att-name='attvalue' [...]".

             For the other types of nodes (text, cdata, comments) the
             expression should contain the node's literal
             content. Again, it is necessary to quote all whitespace
             and special characters as in any expression argument.

             The <location> argument should be one of: `after',
             `before', `into' and `replace'. You may use `into'
             location also to attach an attribute to an element or to
             append some data to a text, cdata or comment node. Note
             also, that `after' and `before' locations may be used to
             append or prepend a string to a value of an existing
             attribute. In that case, attribute name is ignored.

examples:    # append a new Hobbit element to the list of middle-earth
             # creatures
             xsh> xadd element "<creature race='hobbit' manner='good'> \
                    into /middle-earth/creatures

             # name him Bilbo
             xsh> xadd attribute "name='Bilbo'" \
                    into /middle-earth/creatures/creature[@race='hobbit'][last()]

see also:    add, move, xmove
H1
'add' => <<'H1',
usage:       add <node-type> <expression> <location> <xpath>

aliases:     insert

description: Works just like xadd, except that the new node
             is attached only the first node matched.

see also:    xadd, move, xmove
H1
'copy' => <<'H1',
usage:       copy <xpath> <location> <xpath>

aliases:     cp

description: Copies nodes matching the first <xpath> to the
             destinations determined by the <location> directive
             relative to the second <xpath>. If more than one node
             matches the first <xpath> than it is copied to the
             position relative to the corresponding node matched by
             the second <xpath> according to the order in which are
             nodes matched. Thus, the n'th node matching the first
             <xpath> is copied to the location relative to the n'th
             node matching the second <xpath>. The possible values for
             <location> are: after, before, into, replace and cause
             copying the source nodes after, before, into (as the last
             child-node).  the destination nodes. If replace
             <location> is used, the source node is copied before the
             destination node and the destination node is removed.

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

examples:    # replace living-thing elements in the document b with
             # the coresponding creature elements of the document a.
             xsh> copy a://creature replace b://living-thing

see also:    xcopy, add, xadd, move, xmove
H1
'xcopy' => <<'H1',
usage:       xcopy <xpath> <location> <xpath>

aliases:     xcp

description: xcopy is similar to copy, but copies *all* nodes matching
             the first <xpath> to *all* destinations determined by the
             <location> directive relative to the second <xpath>. See copy
             for detailed description of xcopy arguments.

examples:    xsh> xcopy a:/middle-earth/creature into b://world
             copy all middle-earth creatures within the document a
             into every world of the document b.

see also:    copy, add, xadd, move, xmove
H1
'move' => <<'H1',
usage:       move <xpath> <location> <xpath>

aliases:     mv

description: like copy, except that move removes the source nodes
             after a succesfull copy. See copy for more detail.

see also:    copy, xmove, add, xadd
H1
'xcopy' => <<'H1',
usage:       xmove <xpath> <location> <xpath>

aliases:     xmv

description: like xcopy except that xmove removes the source nodes
             after a succesfull copy. See xcopy for more detail.

see also:    xcopy, move, add, xadd
H1
'exec' => <<'H1',
usage:       exec <expression> [<expression> ...]

aliases:     system

description: execute the system command(s) in <expression>s.

examples:    # count words in "hallo wold" string, then print
             # name of your machine's operating system.

             exec echo hallo world       # prints hallo world
             exec "echo hallo word | wc" # counts words in hallo world
             exec uname;                 # prints operating system name

see also:    !
H1
'!' => <<'H1',
usage:       ! <shell-commands>

description: execute the given system command(s). The arguments
             of ! are considered to begin just after the ! character
             and span across the whole line.

examples:    # list current directory
             xsh> !ls
             # the follwoing commands are equivalent
             xsh> !ls | grep \\.xml$
             xsh> !ls *.xml
             # semicolon is a part of the command:
             xsh> exec echo -n hallo; echo "world " # prints hallo world

see also:    exec
H1
'files' => <<'H1',
usage:       files

description: List open files and their identifiers.

see also:    open, close
H1
'variables' => <<'H1',
usage:       var, vars

description: List all defined variables and their values.

see also:    files
H1
'saveas' => <<'H1',
usage:       saveas <id> <filename> [encoding <encoding>]

description: Save the document identified by <id> as a XML file named
             <filename>, possibly converting it from its original
             encoding to <encoding>.

see also:    open, close, enc
H1
'save' => <<'H1',
usage:       save <id> [encoding <encoding>]

description: Save the document identified by <id> to its original XML
             file, possibly converting it from its original encoding
             to <encoding>.

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

examples:    xsh> open x=mydoc.xml # open a document

             # quote file name if it contains whitespace
             xsh> open y="document with a long name with spaces.xml"

             # you may omit the word open (I'm clever enough to find out).
             xsh> z=mybook.xml

             # use z: prefix to identify the document opened with the
             # previous comand in an XPath expression.
             xsh> list z://chapter/title

see also:    save, close, clone
H1
'cd' => <<'H1',
usage:       cd <expression>

aliases:     chdir

description: Changes the working directory to <expression>, if
	     possible.  If <expression> is omitted, changes to the
	     directory specified in HOME environment variable, if set;
	     if not, changes to the directory specified by LOGDIR
	     environment variable.

H1
'print' => <<'H1', 

usage:       print <expression> [<expression> ...]

aliases:     echo

description: Interpolate and print given expression(s).

H1
'assign' => <<'H1', 

usage:       assign $<id>=<expression>

aliases:     $<id>=<expression>

description: Store the result of interpolation of the <expression> in
             a variable named $<id>. The variable may be later used in
             other expressions or even in perl-code as $<id> or
             ${<id>}.

see also   : variables

H1
'call' => <<'H1', 

usage:       call <id>

description: Call an XSH subroutine named <id> previously created
             using def.

see also:    def

H1
'debug' => <<'H1', 

usage:       debug

description: Turn on debugging messages.

see also:    nodebug

H1
'nodebug' => <<'H1', 

usage:       nodebug

description: Turn off debugging messages.

see also:    debug

H1
'def' => <<'H1', 

usage:       def <id> <command-block>

aliases:     define

description: Define a new XSH routine named <id>. The <command-block>
             may be later invoked using the `call <id>' command.

see also:    call

H1
'include' => <<'H1', 

usage:       include <filename>

aliases:     .

description: Include a file named <filename> and execute all XSH
             commands therein.

H1
'encoding' => <<'H1', 

usage:       encoding <encoding>

description: Set the default output character encoding.

H1
'query-encoding' => <<'H1', 

usage:       query-encoding <encoding>

description: Set the default query character encoding.

H1
'quiet' => <<'H1', 

usage:       quiet

description: Turn off verbose messages.

see also:    verbose

H1
'verbose' => <<'H1',

usage:       verbose

description: Turn on verbose messages.

see also:    quiet

H1
'run-mode' => <<'H1',

usage:       run-mode

description: Switch into normal XSH mode in which all commands are
             executed.

see also:    test-mode

H1
'test-mode' => <<'H1',

usage:       test-mode

description: Switch into test mode in which no commands are actually
             executed and only command syntax is checked.

see also:    run-mode

H1
'create' => <<'H1',

usage:       create <id> <expression>

alias:       new

description: Create a new document using <expression> to form the root
             element and associate it with the given identifier.

examples:    xsh> create t1 root
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

see also:    open, clone

H1
);

1;
