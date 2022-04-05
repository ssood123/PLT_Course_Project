/* Ocamlyacc parser for InteGraph */


%{
open Ast

%}

%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token PLUS MINUS TIMES DIVIDE PLUSELEM MINUSELEM TIMESELEM DIVIDEELEM ASSIGN
%token SEMI COMMA PERIOD
%token NOT AND OR EQ NEQ LT LEQ GT GEQ
%token INT FLOAT STRING BOOL MATRIX VOID
%token TRANSPOSE FUNC LENROW LENCOL RETURN IF FOR WHILE ELSE MOD
%token <int> LITERAL
%token <bool> BOOLLIT
%token <string> ID FLOATLIT
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
%left PLUSELEM MINUSELEM 
%left PLUS MINUS
%left TIMESELEM DIVIDEELEM
%left TIMES DIVIDE MOD
%right NOT

%%

program:
  decls EOF { $1 }

decls:
   /* nothing */ { ([], [])               }
 | decls vdecl{ (($2 :: fst $1), snd $1) }
 | decls fdecl { (fst $1, ($2 :: snd $1)) }

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


vdecl_list:
    /* nothing */    { [] }
  | vdecl_list vdecl { $2 :: $1 }

vdecl:
   typ ID SEMI { ($1, $2) }

typ:
    INT        { Int           }
  | BOOL       { Bool          }
  | FLOAT      { Float         }
  | VOID       { Void          }
  | STRING     { String        }
  | typ MATRIX LBRACK LITERAL RBRACK LBRACK LITERAL RBRACK   { Matrix($1, $4, $7) }


formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    typ ID                   { [($1,$2)]     }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }


stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

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
  | ID ASSIGN expr   { Assign($1, $3)       }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN expr RPAREN        { $2            }
  | LBRACK mat_opt RBRACK     { Mat($2)       }
  | LENCOL LPAREN ID RPAREN            { LenCol($3)       }
  | LENROW LPAREN ID RPAREN           { LenRow($3)       }
  | TRANSPOSE LPAREN ID RPAREN       { Transpose($3)      }
/* missing assignment for matrix elements */
  | ID LBRACK expr RBRACK LBRACK expr RBRACK ASSIGN expr {  MatAssign($1, $3, $6, $9)   }




  | ID LBRACK expr RBRACK LBRACK expr RBRACK { MatElem($1, $3, $6)    }
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
  | args COMMA expr { $3 :: $1 }

mat_opt:
    /* nothing */ { [] }
  | row_list      { $1 }

row_list:
    LBRACK row_single RBRACK                { [$2]        }
  | row_list COMMA LBRACK row_single RBRACK {  $4 :: $1 }

row_single:
    /* nothing */            { []       }
  | expr                     { [$1]    }
  | row_single COMMA expr    { $3 :: $1 }
