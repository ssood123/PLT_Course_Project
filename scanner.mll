
let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z']

rule token = parse
  [' ' ] { token lexbuf } (* Whitespace *)
  | "[*"   { comment lexbuf }           (* Comments *)
  | '('      { LPAREN }
  | ')'      { RPAREN }
  | '{'      { LBRACE }
  | '}'      { RBRACE }
  | ';'      { SEMI }
  | ','      { COMMA }
  | '+'      { PLUS }
  | '-'      { MINUS }
  | '*'      { TIME }
  | '\'      { DEVIDE }
  | '%'      { MOD }
  | '='      { ASSIGN }
  | "=="     { EQ }
  | "!="     { NEQ }
  | '<'      { LSTHAN }
  | "<="     { LSEQTHAN }
  | '>'      { GRTHAN }
  | ">="     { GREQTHAN }
  | "&&"     { AND }
  | "||"     { OR }
  | "if"     { IF }
  | "else"   { ELSE }
  | "while"  { WHILE }
  | "return" { RETURN }
  | "int"    { INT }
  | "bool"   { BOOL }
  | "True"   { BLIT(true)  }
  | "False"  { BLIT(false) }
  | "\n"     { NEWLINE  }
  | "\t"     { TAB       }
  | 
  | digit+ as lem  { LITERAL(int_of_string lem) }
  | letter (digit | letter | '_')* as lem { ID(lem) }
  | eof { EOF }
  | _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

  and comment = parse
    "*]" { token lexbuf }
    | _    { comment lexbuf }
