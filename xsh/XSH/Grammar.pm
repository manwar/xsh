package XSH::Grammar;

use strict;
use Parse::RecDescent;
use vars qw/$grammar/;

$Parse::RecDescent::skip = '(\s|\n|#[^\n]*)*';
$grammar=<<'_EO_GRAMMAR_';

  TOKEN: /\S+/

  STRING: /([^'"\$\\ \t\n\r|;]|\$[^{]|\$\{[^{]|]|\\.)+/
     { local $_=$item[1];
       s/\\([^\$])/$1/g;
       $_;
     }

  single_quoted_string: /\'([^\'\\]|\\\'|\\\\|\\[^\'\\])*\'/
     { local $_=$item[1];
       s/^\'|\'$//g;
       s/\\([\'\\])/$1/g;
       $_;
     }

  double_quoted_string: /\"([^\"\\]|\\.)*\"/
     { local $_=$item[1];
       s/^\"|\"$//g;
       s/\\(.)/$1/g;
       $_;
     }

  exp_inline_count : /\${{([^}]|}[^}])*}}/

  exp_part: STRING | exp_inline_count |
            single_quoted_string | double_quoted_string

  expressions : expression expressions { [$item[1],@{$item[2]}] }
              | expression             { [$item[1]] }

  expression: exp_part <skip:""> expression  { "$item[1]$item[3]" }
            | exp_part { $item[1] }

  variable: '$' <skip:""> ID { "$item[1]$item[3]" }

  ID: /[a-zA-Z_][a-zA-Z0-9_]*/

  startrule : statement eof
            | <error>

  eof       : /$/

  statement : shell
            | commands '|' cmdline { XSH::Functions::pipe_command($item[1],$item[3]); }
            | commands { XSH::Functions::run_commands($item[1]); }
            | <error:error while parsing line $thisline near $text>

  shell : /!\s*/ cmdline { XSH::Functions::sh($item[2]); }
  cmdline : /[^\n]*/

  option :  /quiet/ { [\&XSH::Functions::set_opt_q,1] }
            | /verbose/ { [\&XSH::Functions::set_opt_q,0] }
            | /test-mode/ { XSH::Functions::set_opt_c(1); }
            | /run-mode/ { XSH::Functions::set_opt_c(0); }
            | /debug/ { [\&XSH::Functions::set_opt_d,1] }
            | /nodebug/ { [\&XSH::Functions::set_opt_d,0] }
            | /encoding\s/ expression { [\&XSH::Functions::set_encoding,$item[2]]; }
            | /query-encoding\s/ expression { [\&XSH::Functions::set_qencoding,$item[2]]; }

  commands : command ';' commands { [ @{$item[1]},@{$item[3]} ]; }
           | command ';' { $item[1]; }
           | command


  block     : '{' commands '}'              { $item[2]; }

  command   : (copy_command | move_command | list_command | exit_command
            | prune_command | map_command | close_command | open_command
            | valid_command | validate_command | list_dtd_command
            | print_enc_command | cd_command
            | clone_command | count_command | eval_command | save_command
            | files_command | xslt_command | insert_command | help_command
            | exec_command  | call_command | include_command | assign_command
            | print_var_command | var_command | print_command
            | create_command | list_defs_command | select_command
            | option | compound)
            { [$item[1]] }

  compound  : /if\s/ xpath (command|block) { [\&XSH::Functions::if_statement,$item[2],$item[3]] }
            | /unless\s|if\s+!/ xpath (command|block) { [\&XSH::Functions::unless_statement,$item[2],$item[3]] }
            | /while\s/ xpath (command|block) {
              [\&XSH::Functions::while_statement,$item[2],$item[3]];
            }
            | /foreach\s/ xpath (command|block) {
              [\&XSH::Functions::foreach_statement,$item[2],$item[3]];
            }
            | /def\s|define\s/ ID (command|block) { [\&XSH::Functions::def,$item[2],$item[3]] }

  assign_command : variable '=' xpath     { [\&XSH::Functions::xpath_assign,$item[1],$item[3]]; }
                 | /assign\s/ variable '=' xpath  { [\&XSH::Functions::xpath_assign,$item[2],$item[4]]; }

  print_var_command : variable { [\&XSH::Functions::print_var,$item[1]] }

  list_defs_command : /defs/ { [\&XSH::Functions::list_defs] }

  include_command : /\.\s|include\s/ filename { [\&XSH::Functions::include,$item[2]] }

  call_command : /call\s/ ID { [\&XSH::Functions::call,$item[2]]; }

  help_command : /\?|help\s/ expression { [\&XSH::Functions::help,$item[2]]; }
               | /\?|help/ { [\&XSH::Functions::help]; }

  exec_command : /exec\s|system\s/ expressions
               { [\&XSH::Functions::sh,join(" ",@{$item[2]})] }

  xslt_command : xslt_alias ID filename ID /params|parameters\s/ paramlist
               { [\&XSH::Functions::xslt,@item[2,3,4,6]]; }
               | xslt_alias ID filename ID
               { [\&XSH::Functions::xslt,@item[2,3,4]]; }

  paramlist    : param paramlist { [@{$item[1]},@{$item[2]}]; }
               | param

  param        : /[^=\s]+/ '=' expression { [$item[1],$item[3]]; }

  xslt_alias : /transform\s|xslt?\s|xsltproc\s|process\s/

  files_command : 'files' { [\&XSH::Functions::files]; }

  var_command   : /variables|vars|var/ { [\&XSH::Functions::variables]; }


  copy_command : /cp\s|copy\s/ xpath loc xpath { [\&XSH::Functions::copy,@item[2,4,3]]; }
               | /xcp\s|xcopy\s/ xpath loc xpath { [\&XSH::Functions::copy,@item[2,4,3],1]; }

  cd_command : /cd\s|chdir\s/ filename { [\&XSH::Functions::cd,$item[2]]; }
             | /cd|chdir/  { [\&XSH::Functions::cd]; }

  insert_command : /insert\s|add\s/ nodetype expression loc xpath
                 { [\&XSH::Functions::insert,@item[2,3,5,4]]; }
                 | /xinsert\s|xadd\s/ nodetype expression loc xpath
                 { [\&XSH::Functions::insert,@item[2,3,5,4],1]; }

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
                  { [\&XSH::Functions::move,@item[2,4,3]]; }
               | /xmv\s|xmove\s/ xpath loc xpath
                  { [\&XSH::Functions::move,@item[2,4,3],1]; }

  clone_command : /dup\s|clone\s/ ID /\s*=\s*/ ID { [\&XSH::Functions::clone,@item[2,4]]; }

  list_command : /list\s|ls\s/ xpath    { [\&XSH::Functions::list,$item[2]]; }

  count_command : /count\s|xpath\s/ xpath { [\&XSH::Functions::print_count,$item[2]];}

  eval_command : /eval\s|perl\s/ (<perl_codeblock>|perl_expression) { [\&XSH::Functions::print_eval,$item[2]];}

  prune_command : /rm\s|remove\s|prune\s|delete\s|del\s/ xpath  { [\&XSH::Functions::prune,$item[2]]; }

  print_command : /print\s|echo\s/ expressions { [\&XSH::Functions::echo,@{$item[2]}]; }
                | /print|echo/ {  [\&XSH::Functions::echo]; }

  map_command : /map\s|sed\s/ (<perl_codeblock>|perl_expression) xpath
				       { [\&XSH::Functions::perlmap,@item[3,2]]; }

  close_command : /close\s/ ID
				       { [\&XSH::Functions::close_doc,$item[2]]; }

  select_command : /select\s/ ID       { [\&XSH::Functions::set_last_id,$item[2]]; }

  open_command : /open\s/ ID /\s*=\s*/ filename
				       { [\&XSH::Functions::open_doc,@item[2,4]]; }
               | ID /\s*=\s*/ filename
				       { [\&XSH::Functions::open_doc,@item[1,3]]; }

  create_command : /new\s|create\s/ ID expression
				       { [\&XSH::Functions::create_doc,@item[2,3]]; }

  save_command : /saveas\s/ ID filename /encoding\s/ expression
                                       { [\&XSH::Functions::save_as,@item[2,3,5]]; }
               | /saveas\s/ ID filename
                                       { [\&XSH::Functions::save_as,@item[2,3]]; }
               | /save\s/ ID /encoding\s/
                                       { [\&XSH::Functions::save_as,$item[2],$XSH::Functions::files{$item[2]},
                                                       $item[4]]; }
               | /save\s/ ID           { [\&XSH::Functions::save_as,$item[2],$XSH::Functions::files{$item[2]}]; }

  list_dtd_command : /dtd\s/ ID        { [\&XSH::Functions::list_dtd,$item[2]]; }
                   | /dtd(\s|$)/       { [\&XSH::Functions::list_dtd,undef] }


  print_enc_command: /enc\s/ ID        { [\&XSH::Functions::print_enc,$item[2]]; }
                   | /enc(\s|$)/       { [\&XSH::Functions::print_enc,undef] }

  validate_command : /validate\s/ ID   { [\&XSH::Functions::validate_doc,$item[2]]; }
                   | /validate(\s|$)/  { [\&XSH::Functions::validate_doc,undef] }

  valid_command : /valid\s/ ID         { [\&XSH::Functions::valid_doc,$item[2]]; }
                | /valid(\s|$)/        { [\&XSH::Functions::valid_doc,undef] }

  exit_command : /exit\s|quit\s/ expression { [\&XSH::Functions::quit,$item[2]]; }
               | /exit|quit/           { [\&XSH::Functions::quit,0]; }

  filename : expression

  xpath : ID ":" xp                    { [@item[1,3]] }
        | xp                           { [undef, $item[1]] }
        | <error>

  xp : xpsimple <skip:""> (xpfilters|xpbracket) <skip:""> xp
                                       { "$item[1]$item[3]$item[5]"; }
     | xpsimple <skip:""> (xpfilters|xpbracket)
                                       { "$item[1]$item[3]"; }
     | xpsimple
     | xpstring

  xpfilters : xpfilter <skip:""> xpfilters
                                       { "$item[1]$item[3]" }
            | xpfilter

  xpfilter : "[" xpinter "]"           { "[$item[2]]"; }

  xpbracket: "(" xpinter ")"           { "($item[2])"; }

  xpinter : xps (xpfilters|xpbracket) <skip:""> xpinter
                                       { "$item[1]$item[2]$item[4]"; }
          | xps

  xps : /([^][()'"]|'[^']*'|"[^"]*")*/

  xpstring : /'[^']*'|"[^"]*"/

  xpsimple : /[^]"' [();]+/
           | xpbracket


  perl_expression : expression

_EO_GRAMMAR_

sub compile {
  Parse::RecDescent->Precompile($grammar,"XSH::Parser");
}

sub new {
  return new Parse::RecDescent ($grammar);
}

1;
