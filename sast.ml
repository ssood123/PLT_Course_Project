open Ast


type sexpr = typ * sx
and sx = SLiteral of int
| SFliteral of string
| SBoolLit of bool
| SId of string
| SBinop of sexpr * op * sexpr
| SUnop of uop * sexpr
(* | SAssign of sexpr * sexpr *)
| SAssign of string * sexpr
| SMatAssign of string * sexpr * sexpr * sexpr
| SCall of string * sexpr list
| SNoexpr
| SMatrixDef of typ * (sexpr list list)
| SLenRow of int
| SLenCol of int
| SStrLit of string
| SMatElem of string * sexpr * sexpr
| STranspose of string * typ
| SRotate of string * typ
type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SFor of sexpr * sexpr * sexpr * sstmt
  | SWhile of sexpr * sstmt

 type sfunc_decl =
 {
    styp : typ;
    sfname : string;
    sformals : bind list;
    slocals : bind list;
    sbody : sstmt list;
  }

type sprogram = bind list * sfunc_decl list

(* Pretty printing *)

let rec string_of_sexpr (t, e) =
  "(" ^ string_of_typ t ^ " : " ^ (match e with
    SLiteral(l) -> string_of_int l
  | SBoolLit(true) -> "true"
  | SBoolLit(false) -> "false"
  | SStrLit(l) -> "\"" ^ (String.escaped l) ^ "\""
  | SFliteral(l) -> l
  | SMatrixDef(_,_) -> "matrixDefinition"
  | SId(s) -> s
  | SLenCol(m) -> "lenCol(" ^ (string_of_int m) ^ ")"
  | SLenRow(m) -> "lenRow(" ^ (string_of_int m) ^ ")"
  | STranspose (s,m) -> "transpose(" ^ string_of_typ m ^ ")"
  | SRotate(s, m) -> "rotate(" ^ string_of_typ m ^ ")"
  | SMatElem (s,e1,e2) -> s ^ "[" ^ string_of_sexpr e1 ^ "]" ^ "[" ^ string_of_sexpr e2 ^ "]"
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  (* | SAssign(e1, e2) -> string_of_sexpr e1 ^ " = " ^ string_of_sexpr e2 *)
  | SAssign(v, e) ->  v ^ " = " ^ string_of_sexpr e
  | SMatAssign(s,e1,e2,e3) -> "Matrix "^ s^ " row "^ string_of_sexpr e1 ^ " column "^ string_of_sexpr e2 ^ " equals " ^ string_of_sexpr e3
  | SCall(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SNoexpr -> ""
              ) ^ ")"


let rec string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  | SIf(e, s, SBlock([])) ->
      "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SFor(e1, e2, e3, s) ->
      "for (" ^ string_of_sexpr e1  ^ " ; " ^ string_of_sexpr e2 ^ " ; " ^
      string_of_sexpr e3  ^ ") " ^ string_of_sstmt s
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s

let string_of_sfdecl fdecl =
  string_of_typ fdecl.styp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map snd fdecl.sformals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.slocals) ^
  String.concat "" (List.map string_of_sstmt fdecl.sbody) ^
  "}\n"

let string_of_sprogram (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_sfdecl funcs)
