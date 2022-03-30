open Ast
type sexpr = typ * sx

type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SFor of sexpr * sexpr * sexpr * sstmt
  | SWhile of sexpr * sstmt

type sexpr = typ * sx
and sx = SLiteral of int
| SFliteral of string
| SBoolLit of bool
| SId of string
| SBinop of sexpr * op * sexpr
| SUnop of uop * sexpr
| SAssign of string * sexpr
| SCall of string * sexpr list
| SNoexpr
| SMat of sexpr list list
| SLenRow of int
| SLenCol of int
| SStrLit of string
| SMatElem of string * sexpr * sexpr
| STranspose of string * typ

 type sfunc_decl = 
 {
    styp : typ;
    sfname : string;
    sformals : bind list;
    slocals : bind list;
    sbody : sstmt list;
  }

type sprogram = bind list * sfunc_decl list