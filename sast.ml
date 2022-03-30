(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sexpr = typ * sx
and sx =
    SLiteral of int
  | SFliteral of string
  | SBoolLit of bool
(* Whats the difference between StrLit and SId? *)
  | SStrLit of string
  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SAssign of string * sexpr
  (* call *)
  | SCall of string * sexpr list
  | SMat of sexpr list list 
  | SCol of string
  | SRow of string
  | STran of string
  | SAccess of string * sexpr * sexpr
  | SNoexpr

type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SWhile of sexpr * sstmt



(* func_def: ret_typ fname formals locals body *)
type sfunc_decl = {
  srtyp: typ;
  sfname: string;
  sformals: bind list;
  slocals: bind list;
  sbody: sstmt list;
}

type sprogram = bind list * sfunc_decl list



(* Pretty-printing functions *)
let rec string_of_sexpr (t, e) =
  "(" ^ string_of_typ t ^ " : " ^ (match e with
      | SNoexpr -> "No expr" 
      | SLiteral(l) -> string_of_int l
      | SFliteral(l) -> (*string_of_float*) l
      | SBoolLit(true) -> "true"
      | SBoolLit(false) -> "false"
      | SId(s) -> s
      | SStrLit(l) -> "\"" ^ (String.escaped l) ^ "\""
      | SMat(_) -> "matLit"
      | SRow(s) -> s ^ ".row"
      | SCol(s) -> s ^ ".col"
      | STran(s) -> s ^ ".T"
      | SBinop(e1, o, e2) ->
        string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
      | SAccess(s, r, c) -> s ^ "[" ^ string_of_sexpr r ^ "]" ^ "[" ^ string_of_sexpr c ^ "]"
      | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e 
      | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
      | SCall(f, el) ->       f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")" ) ^ ")" 


let rec string_of_sstmt = function
    SBlock(stmts) ->
    "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n"
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n"
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
                       string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_sexpr e1  ^ " ; " ^ string_of_sexpr e2 ^ " ; " ^
      string_of_sexpr e3  ^ ") " ^ string_of_sstmt s
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s


(* does it need this piece?? 
let string_of_styp = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  | Void -> "void"
  | String -> "string"
  | Matrix(_, r, c) -> "matrix [" ^ (string_of_int r) ^ "][" ^ string_of_int c ^ "]"
(*  | Array ()*)


*)




let string_of_sfdecl fdecl =
  string_of_typ fdecl.srtyp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map snd fdecl.sformals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.slocals) ^
  String.concat "" (List.map string_of_sstmt fdecl.sbody) ^
  "}\n"

let string_of_sprogram (vars, funcs) =
  "\n\nSementically checked program: \n\n" ^
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_sfdecl funcs)