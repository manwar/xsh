package XML::XSH::CompletionList;

use strict;
use vars qw(@XSH_COMMANDS @XSH_NOXPATH_COMMANDS);

@XSH_COMMANDS=qw(
.
?
add
assign
backups
call
catalog
cd
chdir
chxpath
clone
close
complete-attributes
complete_attributes
copy
count
cp
create
debug
def
define
defs
del
delete
doc-info
doc_info
docs
documents
dtd
dup
echo
enc
encoding
eval
exec
exit
files
flags
fold
for
foreach
get
help
if
include
indent
insert
iterate
keep-blanks
keep_blanks
last
lcd
list
load-ext-dtd
load-xinclude
load-xincludes
load_ext_dtd
load_xinclude
load_xincludes
local
locate
ls
map
move
mv
namespaces
new
next
nobackups
nodebug
normalize
open
options
parser-completes-attributes
parser-expands-entities
parser-expands-xinclude
parser_completes_attributes
parser_expands_entities
parser_expands_xinclude
pedantic-parser
pedantic_parser
perl
prev
print
print_value
process
process-xinclude
process-xincludes
process_xinclude
process_xincludes
prune
pwd
query-encoding
query_encoding
quiet
quit
recovering
redo
regfunc
register-function
register-namespace
register-xhtml-namespace
register-xsh-namespace
regns
regns-xhtml
regns-xsh
remove
rename
return
rm
run-mode
run_mode
save
sed
select
sort
stream
strip-whitespace
strip_whitespace
switch-to-new-documents
switch_to_new_documents
system
test-mode
test_mode
throw
transform
try
undef
undefine
unfold
unless
unregfunc
unregister-function
unregister-namespace
unregns
valid
validate
validation
var
variables
vars
verbose
version
while
xadd
xcopy
xcp
xinclude
xincludes
xinsert
xmove
xmv
xpath-axis-completion
xpath-completion
xpath_axis_completion
xpath_completion
xsl
xslt
xsltproc
xupdate
);

1;
@XSH_NOXPATH_COMMANDS=qw(
assign
local
options
flags
defs
include
\.
call
help
\?
exec
system
xslt
transform
xsl
xsltproc
process
documents
files
docs
variables
vars
var
lcd
chdir
insert
add
xinsert
xadd
clone
dup
perl
eval
print
echo
sort
map
sed
rename
close
select
open
create
new
save
dtd
enc
validate
valid
exit
quit
process-xinclude
process_xinclude
process-xincludes
process_xincludes
xinclude
xincludes
load_xincludes
load-xincludes
load_xinclude
load-xinclude
pwd
xupdate
redo
next
prev
last
return
throw
catalog
register-namespace
regns
unregister-namespace
unregns
register-xhtml-namespace
regns-xhtml
register-xsh-namespace
regns-xsh
register-function
regfunc
unregister-function
unregfunc
stream
xpath-completion
xpath_completion
xpath-axis-completion
xpath_axis_completion
doc-info
doc_info
);

1;
