type token =
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | LBRACK
  | RBRACK
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | PLUSELEM
  | MINUSELEM
  | TIMESELEM
  | DIVIDEELEM
  | ASSIGN
  | SEMI
  | COMMA
  | PERIOD
  | NOT
  | AND
  | OR
  | EQ
  | NEQ
  | LT
  | LEQ
  | GT
  | GEQ
  | INT
  | FLOAT
  | STRING
  | BOOL
  | MATRIX
  | VOID
  | TRANSPOSE
  | FUNC
  | LENROW
  | LENCOL
  | RETURN
  | IF
  | FOR
  | WHILE
  | ELSE
  | MOD
  | LITERAL of (int)
  | BOOLLIT of (bool)
  | ID of (string)
  | FLOATLIT of (string)
  | STRINGLIT of (string)
  | EOF

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
