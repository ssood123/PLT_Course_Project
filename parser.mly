

%{
open Ast

%}

%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token PLUS MINUS TIMES DIVIDE PLUSELEM MINUSELEM TIMESELEM DIVIDEELEM ASSIGN
%token SEMI COMMA PERIOD
%token NOT AND OR EQ NEQ LT LEQ GT GEQ
%token INT FLOAT STRING BOOL MATRIX VOID
%token TRANSPOSE FUNC LENROW LENCOL ROWNUM RETURN IF FOR WHILE ELSE MOD
%token <int> LITERAL
%token <bool> BOOLLIT
%token <string> ID
%token <string> FLOATLIT
%token <string> STRINGLIT
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMESELEM DIVIDEELEM
%left TIMES DIVIDE
%right NOT

%%

program:
  decls EOF { $1 }

decls:
   /* nothing */ { ([], [])               }
 | vdecl decls { (($1 :: fst $2), snd $2) }
 | fdecl decls { (fst $2, ($1 :: snd $2)) }


vdecl_list:
    /* nothing */    { [] }
  | vdecl vdecl_list { $1 :: $2 }

vdecl:
   typ ID SEMI { ($1, $2) }

typ:
    INT        { Int           }
  | BOOL       { Bool          }
  | FLOAT      { Float         }
  | VOID       { Void          }
  | STRING     { String        }
  | typ MATRIX LBRACK LITERAL RBRACK LBRACK LITERAL RBRACK   { Matrix($1, $4, $7) }

fdecl:
   FUNC typ ID LPAREN formals_opt RPAREN LBRACE vdecl_list stmt_list RBRACE
     { 
        { 
            typ = $2;
	       fname = $3;
	       formals = $5;
	       locals = $8;
	       body = $9 
        } 
    }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    typ ID                   { [($1,$2)]     }
  | typ ID COMMA formal_list { ($1,$2) :: $4 }


stmt_list:
    /* nothing */  { [] }
  | stmt stmt_list { $1 :: $2 }

stmt:
    expr SEMI                               { Expr $1               }
  | LBRACE stmt_list RBRACE                 { Block($2)    }
  | RETURN expr_opt SEMI                    { Return $2             }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7)        }
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5)         }
  | FOR LPAREN expr SEMI expr SEMI expr RPAREN stmt { For($3, $5, $7, $9)   }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }


expr:
    LITERAL          { Literal($1)            }
  | BOOLLIT             { BoolLit($1)            }
  | FLOATLIT	           { Fliteral($1)           }
  | ID               { Id($1)                 }
  | STRINGLIT           { StrLit($1)             }
  | MINUS expr %prec NOT { Unop(Neg, $2)      }
  | NOT expr         { Unop(Not, $2)          }
  | expr ASSIGN expr   { Assign($1, $3)       }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN expr RPAREN        { $2            }
  | LBRACK mat_opt RBRACK     { Mat($2)       }
  | ID PERIOD LENCOL            { Col($1)       }
  | ID PERIOD LENROW             { Row($1)       }
  | ID PERIOD TRANSPOSE          { Tran($1)      }
  | ID LBRACK expr RBRACK LBRACK expr RBRACK { Access($1, $3, $6)    }
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr PLUSELEM expr  { Binop($1, Eladd,   $3) }
  | expr MINUSELEM expr { Binop($1, Elsub,   $3)  }
  | expr TIMESELEM expr  { Binop($1, Elmult,   $3) }
  | expr DIVIDEELEM expr { Binop($1, Eldiv,   $3)  }
  | expr EQ     expr { Binop($1, Equal, $3)   }
  | expr NEQ    expr { Binop($1, Neq,   $3)   }
  | expr LT     expr { Binop($1, Less,  $3)   }
  | expr LEQ    expr { Binop($1, Leq,   $3)   }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | expr MOD    expr {Binop($1, Mod, $3)}
                      
args_opt:
    /* nothing */ { [] }
  | args { $1 }

args:
    expr                    { [$1] }
  | expr COMMA args { $1 :: $3 }

mat_opt:
    /* nothing */ { [] }
  | row_list      { $1 }

row_list:
    LBRACK row_single RBRACK                { [$2]        }
  | row_list COMMA LBRACK row_single RBRACK {  $4 :: $1 }

row_single:
    /* nothing */            { []       }
  | expr                     { [$1]    }
  | expr COMMA  row_single    { $1 :: $3 }
