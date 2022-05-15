/* Ocamlyacc parser for InteGraph */


%{
open Ast

%}

%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token PLUS MINUS TIMES DIVIDE MATRIXPLUSELEM MATRIXMINUSELEM MATRIXTIMESELEM MATRIXDIVIDEELEM ARRAYPLUSELEM ARRAYMINUSELEM ARRAYTIMESELEM ARRAYDIVIDEELEM ASSIGN
%token SEMI COMMA PERIOD
%token NOT AND OR EQ NEQ LT LEQ GT GEQ
%token INT FLOAT STRING BOOL MATRIX ARRAY VOID
%token REVERSE TRANSPOSE ROTATE90 FUNC LENROW LENCOL LENARRAY RETURN IF FOR WHILE ELSE 
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
%left MATRIXPLUSELEM MATRIXMINUSELEM
%left ARRAYPLUSELEM ARRAYMINUSELEM 
%left PLUS MINUS
%left MATRIXTIMESELEM MATRIXDIVIDEELEM
%left ARRAYTIMESELEM ARRAYDIVIDEELEM
%left TIMES DIVIDE 
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
           formals = List.rev $5;
           locals = List.rev $8;
           body = List.rev $9 
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
  | typ ARRAY LBRACK LITERAL RBRACK { Array($1,$4) }
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
  | LBRACE stmt_list RBRACE                 { Block(List.rev $2)    }
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
  | LPAREN array_list RPAREN           { ArrayDef(List.rev $2)      }
  | LBRACK matrix_row_list RBRACK     { MatrixDef(List.rev $2)       }
  | LENARRAY LPAREN ID RPAREN           { LenArr($3) }
  | REVERSE LPAREN ID RPAREN            { Reverse($3) }
  | LENCOL LPAREN ID RPAREN            { LenCol($3)       }
  | LENROW LPAREN ID RPAREN           { LenRow($3)       }
  | TRANSPOSE LPAREN ID RPAREN       { Transpose($3)      }
  | ROTATE90 LPAREN ID RPAREN          { Rotate($3)         }
  | ID LBRACK expr RBRACK LBRACK expr RBRACK { MatElem($1, $3, $6)    }
  | ID LBRACK expr RBRACK {ArrElem($1,$3)   }
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr ARRAYPLUSELEM expr { Binop($1, AddElemArr,   $3) }
  | expr ARRAYMINUSELEM expr { Binop($1, SubElemArr,   $3)  }
  | expr ARRAYTIMESELEM expr  { Binop($1, MultElemArr,   $3) }
  | expr ARRAYDIVIDEELEM expr { Binop($1, DivElemArr,   $3)  }
  | expr MATRIXPLUSELEM expr  { Binop($1, AddElemMat,   $3) }
  | expr MATRIXMINUSELEM expr { Binop($1, SubElemMat,   $3)  }
  | expr MATRIXTIMESELEM expr  { Binop($1, MultElemMat,   $3) }
  | expr MATRIXDIVIDEELEM expr { Binop($1, DivElemMat,   $3)  }
  | expr EQ     expr { Binop($1, Equal, $3)   }
  | expr NEQ    expr { Binop($1, Neq,   $3)   }
  | expr LT     expr { Binop($1, Less,  $3)   }
  | expr LEQ    expr { Binop($1, Leq,   $3)   }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | ID LBRACK expr RBRACK LBRACK expr RBRACK ASSIGN expr {  MatAssign($1, $3, $6, $9)   }
  | ID LBRACK expre RBRACK ASSIGN expre { ArrAssign($1, $3, $6, $9) }
                      
args_opt:
    /* nothing */ { [] }
  | args { List.rev $1 }

args:
    expr                    { [$1] }
  | args COMMA expr { $3 :: $1 }


array_list:
   expr     { [$1] }
   | array_list COMMA expr { $3 :: ($1)}


matrix_row_list:
    LBRACK matrix_row_single RBRACK                { [(List.rev $2)]        }
  | matrix_row_list COMMA LBRACK matrix_row_single RBRACK {  (List.rev $4) :: $1 }

matrix_row_single:
    /* nothing */            { []       }
  | expr                     { [$1]    }
  | matrix_row_single COMMA expr    { $3 :: $1 }
