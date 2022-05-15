

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | AddElemArr | SubElemArr | MultElemArr | DivElemArr | AddElemMat | SubElemMat | MultElemMat | DivElemMat 

type uop = Neg | Not

type typ = Void  | Int | Bool | Float | String | Array of typ * int | Matrix of typ * int * int 

type bind = typ * string


type expr =
    Literal of int
  | Fliteral of string
  | BoolLit of bool
  | StrLit of string
  | Id of string
  | Unop of uop * expr
  | Binop of expr * op * expr
  | Assign of string * expr
  | Call of string * (expr list)
  | ArrayDef of (expr list)
  | MatrixDef of (expr list) list
  | LenArr of string
  | Reverse of string 
  | LenCol of string
  | LenRow of string
  | Transpose of string
  | Rotate of string
  | ArrElem of string * expr
  | MatElem of string * expr * expr
  | MatAssign of string * expr * expr * expr
  | Noexpr



type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | AddElemArr -> "+."
  | SubElemArr -> "-."
  | MultElemArr -> "*."
  | DivElemArr -> "/."
  | AddElemMat -> "+.."
  | SubElemMat -> "-.."
  | MultElemMat-> "*.."
  | DivElemMat -> "/.."
  | Equal -> "=="
  | Neq -> "~="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "and"
  | Or -> "or"

let string_of_uop = function
    Neg -> "-"
  | Not -> "not"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | Fliteral(l) -> l
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | StrLit(l) -> "\"" ^ (String.escaped l) ^ "\""
  | MatrixDef(_) -> "matrixDefinition"
  | ArrayDef(_) -> "arrayDefinition"
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | LenArr(a) -> "lenArr(" ^ a ^ ")"
  | Reverse(a) -> "reverse(" ^ a ^ ")"
  | LenCol(m) -> "lenCol(" ^ m ^ ")"
  | LenRow(m) -> "lenRow(" ^  m ^ ")"
  | Transpose(m) -> "transpose(" ^  m ^ ")"
  | Rotate(m) -> "rotate(" ^ m ^ ")" 
  | ArrElem(a,l) -> a ^ "[" ^ string_of_expr l ^ "]"
  | MatElem(m, r, c) -> m ^ "[" ^ string_of_expr r ^ "]" ^ "[" ^ string_of_expr c ^ "]"
  | MatAssign (s, v1, v2, v3) -> s ^"[" ^ string_of_expr v1 ^ "]" ^ "[" ^ string_of_expr v2 ^ "]" ^ "=" ^ string_of_expr v3
  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s


let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  | Void -> "void"
  | String -> "string"
  | Array(_,l) -> "array[" ^ (string_of_int l) ^ "]"
  | Matrix(_, r, c) -> "matrix[" ^ (string_of_int r) ^ "][" ^ (string_of_int c) ^ "]" 

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_fdecl fdecl =
  "function" ^ " " ^ string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"

let string_of_program (vars, funcs) =
  "\n\nParsed program: \n\n" ^
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)

