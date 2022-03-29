(* Ocamllex scanner for Red-Pandas *)

{ open Parser }


rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "[*"     { comment lexbuf }           (* Comments *)
| "("      { LPAREN }
| ")"      { RPAREN }
| "{"      { LBRACE }
| "}"      { RBRACE }
| "["      { LBRACK }
| "]"      { RBRACK }
| ";"      { SEMI }
| "."      { PERIOD }
| "and"     { AND }
| "or"     { OR }
| "not"      { NOT }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "int"    { INT }
| "bool"   { BOOL }
| "float"  { FLOAT }
| "void"   { VOID }
| "string" { STRING }
| "matrix" { MATRIX }
| "if"     { IF }
| "true"   { BOOLLIT(true)  }
| "false"  { BOOLLIT(false) }
| "colLen"    { LENCOL }
| "rowLen"    { LENROW }
| "function"    { FUNC }
| ","      { COMMA }
| "+"      { PLUS }
| "-"      { MINUS }
| "*"      { TIMES }
| "/"      { DIVIDE }
| "*."     { TIMESELEM }
| "/."     { DIVIDEELEM }
| "TP"      { TRANSPOSE }
| "="      { ASSIGN }
| "=="     { EQ }
| "~="     { NEQ }
| "<"      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*     as tmp { ID(tmp) }
| ['0'-'9']+ as tmp { LITERAL(int_of_string tmp) }
| ['0'-'9']+ '.' ['0'-'9']* as tmp { FLOATLIT(tmp) }
| '"' (['a'-'z' 'A' - 'Z']+ as tmp) '"' { STRINGLIT(tmp) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*]" { token lexbuf }
| _    { comment lexbuf }

