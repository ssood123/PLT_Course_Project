
open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.

   Check each global variable, then check each function *)

let check (globals, functions) =

  (* Verify a list of bindings has no void types or duplicate names *)
  let check_binds (kind : string) (binds : bind list) =
    List.iter (function
	(Void, b) -> raise (Failure ("illegal void " ^ kind ^ " " ^ b))
      | _ -> ()) binds;
    let rec dups = function
        [] -> ()
      |	((_,n1) :: (_,n2) :: _) when n1 = n2 ->
	  raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a) (_,b) -> compare a b) binds)
  in

  (**** Check global variables ****)

  check_binds "global" globals;

  (**** Check functions ****)

  (* Collect function declarations for built-in functions: no bodies *)
  let built_in_decls =
    let add_bind map (name, ty) = StringMap.add name {
      typ = Void;
      fname = name;
      formals = [(ty, "x")];
      locals = []; body = [] } map
    in List.fold_left add_bind StringMap.empty [ ("print", Int);
			                         ("printb", Bool);
			                         ("printf", Float);
			                         ("printbig", Int);
                               ("printStr", String) ]
  in

  (* Add function name to symbol table *)
  let add_func map fd =
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    in match fd with (* No duplicate functions or redefinitions of built-ins *)
         _ when StringMap.mem n built_in_decls -> make_err built_in_err
       | _ when StringMap.mem n map -> make_err dup_err
       | _ ->  StringMap.add n fd map
  in

  (* Collect all function names into one symbol table *)
  let function_decls = List.fold_left add_func built_in_decls functions
  in

  (* Return a function from our symbol table *)
  let find_func s =
    try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let _ = find_func "main" in (* Ensure "main" is defined *)

  let check_function func =
    (* Make sure no formals or locals are void or duplicates *)
    check_binds "formal" func.formals;
    check_binds "local" func.locals;

    (* Raise an exception if the given rvalue type cannot be assigned to
       the given lvalue type *)
    let check_assign lvaluet rvaluet err =
       if lvaluet = rvaluet then lvaluet else raise (Failure err)
    in

    (* Build local symbol table of variables for this function *)
    let symbols = List.fold_left (fun m (t, name) -> StringMap.add name t m)
	                StringMap.empty (globals @ func.formals @ func.locals )
    in

    (* Return a variable from our local symbol table *)
    let type_of_identifier s =
      try StringMap.find s symbols
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr = function
        Literal  l -> (Int, SLiteral l)
      | Fliteral l -> (Float, SFliteral l)
      | BoolLit l  -> (Bool, SBoolLit l)
      | StrLit l   -> (String, SStrLit l)
      | Noexpr     -> (Void, SNoexpr)
      | Id s       -> (type_of_identifier s, SId s)
      | Assign(var, e) as ex ->
          let lt = type_of_identifier var
          and (rt,e') = expr e in
          let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^
            string_of_typ rt ^ " in " ^ string_of_expr ex
          in (check_assign lt rt err, SAssign(var, (rt, e')))
      | Unop(op, e) as ex ->
          let (t, e') = expr e in
          let ty = match op with
            Neg when t = Int || t = Float -> t
          | Not when t = Bool -> Bool
          | _ -> raise (Failure ("illegal unary operator " ^
                                 string_of_uop op ^ string_of_typ t ^
                                 " in " ^ string_of_expr ex))
          in (ty, SUnop(op, (t, e')))
      | Binop(e1, op, e2) as e ->
          let (t1, e1') = expr e1
          and (t2, e2') = expr e2 in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Mult | Div when same && t1 = Int   -> Int
          | Add | Sub | Mult | Div when same && t1 = Float -> Float
          | AddElemArr | SubElemArr | MultElemArr | DivElemArr -> (match (t1, t2) with
                Array(a1,l1), Array(a2,l2) ->
                  if a1 != a2 && l1 = l2 then raise (Failure "illegal binary operator for array of different types")
                  else if a1 = a2 && l1 != l2 then raise (Failure "illegal binary operator for array of different sizes")
                  else if a1 != a2 && l1 != l2 then raise (Failure "illegal binary operator for array of different types and sizes")
                  else Array(a1,l1)
                | _ -> raise (Failure "Not a valid operation for non-array"))
          | AddElemMat| SubElemMat | MultElemMat | DivElemMat -> (match (t1, t2) with
                Matrix(m1,r1,c1), Matrix(m2,r2,c2) ->
                  if m1 != m2 && r1 = r2 && c1 = c2 then raise (Failure "illegal binary operator for matrix of different types")
                  else if m1 = m2 && (r1 != r2 || c1 != c2) then raise (Failure "illegal binary operator for matrix of different sizes")
                  else if m1 != m2 && (r1 != r2 || c1 != c2) then raise (Failure "illegal binary operator for matrix of different types and sizes")
                  else Matrix(m1,r1,c1)
                | _ -> raise (Failure "Not a valid operation for non-matrix"))
          | Equal | Neq            when same               -> Bool
          | Less | Leq | Greater | Geq
                     when same && (t1 = Int || t1 = Float) -> Bool
          | And | Or when same && t1 = Bool -> Bool
          | _ ->  raise (
                  Failure ("illegal binary operator " ^
                       string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                       string_of_typ t2 ^ " in " ^ string_of_expr e))
          in (ty, SBinop((t1, e1'), op, (t2, e2')))
      | Call(fname, args) as call ->
          let fd = find_func fname in
          let param_length = List.length fd.formals in
          if List.length args != param_length then
            raise (Failure ("expecting " ^ string_of_int param_length ^
                            " arguments in " ^ string_of_expr call))
          else let check_call (ft, _) e =
            let (et, e') = expr e in
            let err = "illegal argument found " ^ string_of_typ et ^
              " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
            in (check_assign ft et err, e')
          in
          let args' = List.map2 check_call fd.formals args
          in (fd.typ, SCall(fname, args'))
      | ArrElem(a, l) -> (let (index, index') = expr l in
                            match (index) with
                            (Int) -> (match type_of_identifier a with
                              Array(a1, l) -> (a1, SArrElem(a, (index, index')))
                              |_ -> raise(Failure "Cannot get an element of a non-array")
                            )
                            | _ -> raise(Failure "array index is not an integer"))
      | MatElem(m, r, c) -> (let (rowIndex, rowIndex') = expr r in let (colIndex, colIndex') = expr c in
                            match (rowIndex, colIndex) with
                            (Int, Int) -> (match type_of_identifier m with
                              Matrix(m1, r, c) -> (m1, SMatElem(m, (rowIndex, rowIndex'), (colIndex, colIndex')))
                              |_ -> raise(Failure "Cannot get an element of a non-matrix")
                            )
                            | _ -> raise(Failure "row index or column index is not an integer"))
     | ArrAssign(a, e1, e2) ->
        (
      let (index, index') = expr e1 in
      match (index) with
      (Int)->
         ( let atype= type_of_identifier a in
         match atype with
         Array(a1, e1) ->
          ( let (e2a, e3b) = expr e2 in
            if a1=e2a then
             (a1, SArrAssign(a,(index, index'), (e2a,e3b) ) )

          else raise(Failure "Array and attempted assignement are incompatible types")
          )
         |_-> raise(Failure "Can only perform array assignment to an array")
        )
      |_-> raise(Failure "Must access array elements by Int")

)

      | MatAssign(m, e1, e2, e3)->
(
      let (rowIndex, rowIndex') = expr e1 in
      let (colIndex, colIndex') =expr e2 in
      match (rowIndex, colIndex) with
      (Int, Int)->
         ( let mtype= type_of_identifier m in
         match mtype with
         Matrix(m1, e1, e2) ->
          ( let (e3a, e3b)= expr e3 in
            if m1=e3a then
          (* match e3a with
            e3a -> (m1, SMatAssign(m,(rowIndex, rowIndex'),(colIndex, colIndex'), (e3a,e3b) ) )

            |_-> raise(Failure "Matrix and attempted assignement are incompatible types")
*)           (m1, SMatAssign(m,(rowIndex, rowIndex'),(colIndex, colIndex'), (e3a,e3b) ) )

          else raise(Failure "Matrix and attempted assignement are incompatible types")
          )
         |_-> raise(Failure "Can only perform matrix assignment to a matrix")
        )
      |_-> raise(Failure "Must access matrix elements by Int")

)


      | LenArr(a)     -> (match type_of_identifier a with
                            Array(a,l) -> (Int, SLenArr(l))
                            |_ -> raise(Failure "Cannot find length of non-array"))
      | Reverse(a) -> (match type_of_identifier a with
                            Array(a1,l) -> (Array(a1,l), SReverse(a, Array(a1,l)))
                            |_ -> raise(Failure "Cannot do a transpose of a non-matrix"))
      | LenRow(m)     ->  (match type_of_identifier m with
                            Matrix(m,r,c) -> (Int, SLenRow(r))
                            |_ -> raise(Failure "Cannot find row value of non-matrix"))
      | LenCol(m)     ->   (match type_of_identifier m with
                            Matrix(m,r,c) -> (Int, SLenCol(c))
                            |_ -> raise(Failure "Cannot find column value of non-matrix"))
      | Transpose(m)    -> (match type_of_identifier m with
                            Matrix(m1,r,c) -> (Matrix(m1,c,r), STranspose(m, Matrix(m1,r,c)))
                            |_ -> raise(Failure "Cannot do a transpose of a non-matrix"))
      | Rotate(m)    -> (match type_of_identifier m with
                            Matrix(m1,r,c) -> (Matrix(m1,c,r), SRotate(m, Matrix(m1,r,c)))
                            |_ -> raise(Failure "Cannot rotate a non-matrix"))
      | ArrayDef(arr) -> (let typeOfFirstElement = fst (expr (List.hd(arr))) in
                           List.map (fun e -> if fst (expr e) != typeOfFirstElement then raise(Failure "All elements of the array need have the same type.")) arr);
                          let sArr = (List.map (fun e -> expr e) arr) in
                          let (theTyp, _) = expr (List.hd(arr)) in
                          let elemLen = List.length arr in
                          (Array (theTyp, elemLen), SArrayDef(theTyp, sArr))
      | MatrixDef(arr) -> (let lengthOfFirstElement = List.length (List.hd arr) in
                              List.map (fun e -> if List.length e != lengthOfFirstElement then raise(Failure "All rows of the array should have the same length.")) arr);
                          (let typeOfFirstElement = fst (expr (List.hd(List.hd(arr)))) in
                            List.map (fun e -> List.map (fun d -> if fst (expr d) != typeOfFirstElement then raise(Failure "All elements of the array need have the same type.")) e) arr);
                            let sArr = (List.map (fun e -> List.map expr e) arr) in
                            let (theTyp, _) = expr (List.hd(List.hd(arr))) in
                            let rows = List.length arr in
                            let cols = List.length (List.hd arr) in
                            (Matrix (theTyp, rows, cols), SMatrixDef(theTyp, sArr))
(*check that the types are correct for matrices*)





    in

    let check_bool_expr e =
      let (t', e') = expr e
      and err = "expected Boolean expression in " ^ string_of_expr e
      in if t' != Bool then raise (Failure err) else (t', e')
    in

    (* Return a semantically-checked statement i.e. containing sexprs *)
    let rec check_stmt = function
        Expr e -> SExpr (expr e)
      | If(p, b1, b2) -> SIf(check_bool_expr p, check_stmt b1, check_stmt b2)
      | For(e1, e2, e3, st) ->
	  SFor(expr e1, check_bool_expr e2, expr e3, check_stmt st)
      | While(p, s) -> SWhile(check_bool_expr p, check_stmt s)
      | Return e -> let (t, e') = expr e in
        if t = func.typ then SReturn (t, e')
        else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_expr e))

	    (* A block is correct if each statement is correct and nothing
	       follows any Return statement.  Nested blocks are flattened. *)
      | Block sl ->
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
          in SBlock(check_stmt_list sl)

    in (* body of check_function *)
    { styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      slocals  = func.locals;
      sbody = match check_stmt (Block func.body) with
	SBlock(sl) -> sl
      | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
  in (globals, List.map check_function functions)
