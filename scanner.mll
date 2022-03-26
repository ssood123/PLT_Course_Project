
let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z']

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
  | "[*"   { comment lexbuf }           (* Comments *)
  | '('      { LPAREN }
  | ')'      { RPAREN }
  | '{'      { LBRACE }
  | '}'      { RBRACE }
  | '['      { LBRACK }
  | ']'      { RBRACK }
  | ';'      { SEMI }
  | ','      { COMMA }
  | '.'      { PERIOD }
  | '+'      { PLUS }
  | '-'      { MINUS }
  | '*'      { TIMES }
  | '/'      { DIVIDE }
  | "/."     { DIVIDEEL }
  | "*."     { TIMESEL }
  | '%'      { MOD }
  | '='      { ASSIGN }
  | "=="     { EQ }
  | "!="     { NEQ }
  | '<'      { LT }
  | "<="     { LEQ }
  | '>'      { GT }
  | ">="     { GEQ }
  | "and"    { AND }
  | "or"     { OR }
  | "not"    { NOT }
  | "if"     { IF }
  | "else"   { ELSE }
  | "while"  { WHILE }
  | "return" { RETURN }
  | "int"    { INT }
  | "bool"   { BOOL }
  | "float"  { FLOAT }
  | "void"   { VOID }
  | "true"   { BLIT(true)  }
  | "false"  { BLIT(false) }
  | "string" { STRING }
  | "matrix" { MATRIX }
  | "col"    { COL }
  | "row"    { ROW }
  | "def"    { DEF }
  | digit+ as lem  { LITERAL(int_of_string lem) }
  | letter (digit | letter | '_')* as lem { ID(lem) }
  | '"' letter* '"' as lem { STRING(lem) }
  | digit+ '.' digit+ as lem { FLOAT(lem) }
  | eof { EOF }
  | _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

  and comment = parse
    "*]" { token lexbuf }
    | _    { comment lexbuf }
