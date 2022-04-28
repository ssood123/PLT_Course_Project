(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast
open Sast 

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module *)
let translate (globals, functions) =
  let context    = L.global_context () in
  
  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "integraph" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context
  and pointer_t  = L.pointer_type 
  and array_t    = L.array_type
  in

  (* Return the LLVM type for a integraph type *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | A.String -> pointer_t i8_t
    | A.Matrix(m,r,c) -> 
          (match m with
            A.Int    -> array_t (array_t i32_t c) r
          | A.Float  -> array_t (array_t float_t c) r
          | _        -> raise(Failure "A matrix can't have this type"))
  in

  (* Create a map of global variables after creating each *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n) = 
      let init = match t with
          A.Float -> L.const_float (ltype_of_typ t) 0.0
        | _ -> L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in

  let printf_t : L.lltype = 
      L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
      L.declare_function "printf" printf_t the_module in

  let printbig_t : L.lltype =
      L.function_type i32_t [| i32_t |] in
  let printbig_func : L.llvalue =
      L.declare_function "printbig" printbig_t the_module in

  (* Define each function (arguments and return type) so we can 
     call it even before we've created its body *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types = 
	Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in
  
  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d\t" "fmt" builder
    and string_format_str =  L.build_global_stringptr "%s\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\t" "fmt" builder in

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p = 
        L.set_value_name n p;
	let local = L.build_alloca (ltype_of_typ t) n builder in
        ignore (L.build_store p local builder);
	StringMap.add n local m 

      (* Allocate space for any locally declared variables and add the
       * resulting registers to our map *)
      and add_local m (t, n) =
	let local_var = L.build_alloca (ltype_of_typ t) n builder
	in StringMap.add n local_var m 
      in
      
      let formals = List.fold_left2 add_formal StringMap.empty fdecl.sformals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals fdecl.slocals 
    in

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in

    let accessValue s r c builder a = 
      let specific = L.build_gep (lookup s) [|L.const_int i32_t 0; r; c|] s builder in
      if a then specific else L.build_load specific s builder
    in

    (* Construct code for an expression; return its value *)
    let rec expr builder ((_, e) : sexpr) = match e with
	    SLiteral i  -> L.const_int i32_t i
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      | SStrLit s   -> L.build_global_stringptr s "tmp" builder
      | SAssign (s, e) -> let e' = expr builder e in
                          ignore(L.build_store e' (lookup s) builder); e'
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       -> L.build_load (lookup s) s builder
      | SMatrixDef (t, mat) -> 
        let innertype = match t with 
                A.Float -> float_t
                | A.Int -> i32_t
                | _ -> raise(Failure "The matrix must have an int or float type")
          in
            let innerArray   = List.map Array.of_list ( List.map (List.map (expr builder)) mat ) in
            let listToarray  = Array.of_list ((List.map (L.const_array innertype) innerArray)) in
            L.const_array (array_t innertype (List.length (List.hd mat))) listToarray
      | SLenCol (c)   -> L.const_int i32_t c
      | SLenRow (r)   -> L.const_int i32_t r
      | STranspose (s,t)  -> 
                    (match t with
                    Matrix(Int, c, r) ->
                        let tempAlloc = L.build_alloca (array_t (array_t i32_t c) r) "tempMatrix" builder in
                        for i=0 to (c-1) do
                            for j=0 to (r-1) do
                                (* let temp = accessValue s (L.const_int i32_t i) (L.const_int i32_t j) builder false in *)
                                let getTheElementPtr = L.build_gep (lookup s) [|L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j|] s builder in
                                let temp = L.build_load getTheElementPtr s builder in
                                let l = L.build_gep tempAlloc [| L.const_int i32_t 0; L.const_int i32_t j; L.const_int i32_t i |] "tempMatrix" builder in 
                                L.build_store temp l builder 
                            done
                        done;
                        L.build_load (L.build_gep tempAlloc [| L.const_int i32_t 0 |] "tempMatrix" builder) "tempMatrix" builder
                    | Matrix(Float, c, r) -> 
                        let tempAlloc = L.build_alloca (array_t (array_t float_t c) r) "tempMatrix" builder in
                        for i=0 to (c-1) do
                            for j=0 to (r-1) do
                                (* let temp = accessValue s (L.const_int i32_t i) (L.const_int i32_t j) builder false in *)
                                let getTheElementPtr = L.build_gep (lookup s) [|L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j|] s builder in
                                let temp = L.build_load getTheElementPtr s builder in
                                let l = L.build_gep tempAlloc [| L.const_int i32_t 0; L.const_int i32_t j; L.const_int i32_t i |] "tempMatrix" builder in 
                                L.build_store temp l builder 
                            done
                        done;
                        L.build_load (L.build_gep tempAlloc [| L.const_int i32_t 0 |] "tempMatrix" builder) "tempMatrix" builder)
      | SMatElem (s,r,c) -> let a = expr builder r and b = expr builder c in
                          (accessValue s a b builder false)
      | SBinop ((A.Float,_ ) as e1, op, e2) ->
          let e1' = expr builder e1
          and e2' = expr builder e2 in
          (match op with 
            A.Add     -> L.build_fadd
          | A.Sub     -> L.build_fsub
          | A.Mult    -> L.build_fmul
          | A.Div     -> L.build_fdiv 
          | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
          | A.Neq     -> L.build_fcmp L.Fcmp.One
          | A.Less    -> L.build_fcmp L.Fcmp.Olt
          | A.Leq     -> L.build_fcmp L.Fcmp.Ole
          | A.Greater -> L.build_fcmp L.Fcmp.Ogt
          | A.Geq     -> L.build_fcmp L.Fcmp.Oge
          | A.And | A.Or ->
              raise (Failure "internal error: semant should have rejected and/or on float")
          | _ ->  raise (Failure "error: not a viable int to int operation")
          ) e1' e2' "tmp" builder
      | SBinop (e1, op, e2) ->
          let e1' = expr builder e1
          and e2' = expr builder e2
          and (typ1,_) = e1
          and (typ2,_) = e2  in
          let str1 = (match e1 with (_, SId(s)) -> s | _ -> "") in
          let str2 = (match e2 with (_, SId(s)) -> s | _ -> "") in 
          (match (typ1, typ2) with
          | (Matrix(Int, a1, b1), Matrix(Int, _, b2)) ->
                                (match op with
                                | A.AddElemMat -> 
                                    let temp = L.build_alloca (array_t (array_t i32_t b2) a1) "tmpmat" builder in
                                    for i = 0 to (a1-1) do
                                      for j = 0 to (b2-1) do
                                        let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                        let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                        let final = L.build_add mat1 mat2 "tmp" builder in
                                        let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                        ignore(L.build_store final l builder);
                                      done
                                    done;
                                    L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                  
                                | A.SubElemMat -> 
                                  let temp = L.build_alloca (array_t (array_t i32_t b2) a1) "tmpmat" builder in
                                  for i = 0 to (a1-1) do
                                    for j = 0 to (b2-1) do
                                      let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let final = L.build_sub mat1 mat2 "tmp" builder in
                                      let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                      ignore(L.build_store final l builder);
                                    done
                                  done;
                                  L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                
                                | A.MultElemMat -> 
                                  let temp = L.build_alloca (array_t (array_t i32_t b2) a1) "tmpmat" builder in
                                  for i = 0 to (a1-1) do
                                    for j = 0 to (b2-1) do
                                      let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let final = L.build_mul mat1 mat2 "tmp" builder in
                                      let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                      ignore(L.build_store final l builder);
                                    done
                                  done;
                                  L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                | A.DivElemMat -> 
                                  let temp = L.build_alloca (array_t (array_t i32_t b2) a1) "tmpmat" builder in
                                  for i = 0 to (a1-1) do
                                    for j = 0 to (b2-1) do
                                      let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let final = L.build_sdiv mat1 mat2 "tmp" builder in
                                      let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                      ignore(L.build_store final l builder);
                                    done
                                  done;
                                  L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                  | _ ->  raise (Failure "error: not a viable matrix to matrix operation")    
                                  )      
            | (Matrix(Float, a1, b1), Matrix(Float, _, b2)) ->
                                  (match op with
                                  | A.AddElemMat -> 
                                      let temp = L.build_alloca (array_t (array_t float_t b2) a1) "tmpmat" builder in
                                      for i = 0 to (a1-1) do
                                        for j = 0 to (b2-1) do
                                          let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                          let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                          let final = L.build_fadd mat1 mat2 "tmp" builder in
                                          let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                          ignore(L.build_store final l builder);
                                        done
                                      done;
                                      L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                    
                                  | A.SubElemMat -> 
                                    let temp = L.build_alloca (array_t (array_t float_t b2) a1) "tmpmat" builder in
                                    for i = 0 to (a1-1) do
                                      for j = 0 to (b2-1) do
                                        let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                        let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                        let final = L.build_fsub mat1 mat2 "tmp" builder in
                                        let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                        ignore(L.build_store final l builder);
                                      done
                                    done;
                                  L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                  | A.MultElemMat -> 
                                    let temp = L.build_alloca (array_t (array_t float_t b2) a1) "tmpmat" builder in
                                    for i = 0 to (a1-1) do
                                      for j = 0 to (b2-1) do
                                        let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                        let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                        let final = L.build_fmul mat1 mat2 "tmp" builder in
                                        let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                        ignore(L.build_store final l builder);
                                      done
                                    done;
                                    L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                  
                                | A.DivElemMat -> 
                                  let temp = L.build_alloca (array_t (array_t float_t b2) a1) "tmpmat" builder in
                                  for i = 0 to (a1-1) do
                                    for j = 0 to (b2-1) do
                                      let mat1 = accessValue str1 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let mat2 = accessValue str2 (L.const_int i32_t i) (L.const_int i32_t j) builder false in
                                      let final = L.build_fdiv mat1 mat2 "tmp" builder in
                                      let l = L.build_gep temp [| L.const_int i32_t 0; L.const_int i32_t i; L.const_int i32_t j |] "tmpmat" builder in
                                      ignore(L.build_store final l builder);
                                    done
                                  done;
                                  L.build_load (L.build_gep temp [| L.const_int i32_t 0 |] "tmpmat" builder) "tmpmat" builder
                                  | _ ->  raise (Failure "error: not a viable matrix to matrix operation")    
                                    )      
          | _ -> (match op with
                      A.Add     -> L.build_add
                    | A.Sub     -> L.build_sub
                    | A.Mult    -> L.build_mul
                    | A.Div     -> L.build_sdiv
                    | A.And     -> L.build_and
                    | A.Or      -> L.build_or
                    | A.Equal   -> L.build_icmp L.Icmp.Eq
                    | A.Neq     -> L.build_icmp L.Icmp.Ne
                    | A.Less    -> L.build_icmp L.Icmp.Slt
                    | A.Leq     -> L.build_icmp L.Icmp.Sle
                    | A.Greater -> L.build_icmp L.Icmp.Sgt
                    | A.Geq     -> L.build_icmp L.Icmp.Sge
                    | _ ->  raise (Failure "error: not a viable operation")    ) e1' e2' "tmp" builder                 
        )
          
          
          
           
      | SUnop(op, ((t, _) as e)) ->
          let e' = expr builder e in
	  (match op with
	    A.Neg when t = A.Float -> L.build_fneg 
	  | A.Neg                  -> L.build_neg
          | A.Not                  -> L.build_not) e' "tmp" builder
      | SCall ("print", [e]) | SCall ("printb", [e]) ->
	      L.build_call printf_func [| int_format_str ; (expr builder e) |]
	    "printf" builder
      | SCall ("printbig", [e]) ->
	      L.build_call printbig_func [| (expr builder e) |] "printbig" builder
      | SCall ("printf", [e]) -> 
	      L.build_call printf_func [| float_format_str ; (expr builder e) |]
	    "printf" builder
      | SCall ("printStr", [e]) -> 
        L.build_call printf_func [| string_format_str ; (expr builder e) |] 
        "printf" builder
      | SCall (f, args) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
	 let llargs = List.rev (List.map (expr builder) (List.rev args)) in
	 let result = (match fdecl.styp with 
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder
    in
    
    (* LLVM insists each basic block end with exactly one "terminator" 
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
	Some _ -> ()
      | None -> ignore (instr builder) in
	
    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)

    let rec stmt builder = function
	    SBlock sl -> List.fold_left stmt builder sl
      | SExpr e -> ignore(expr builder e); builder 
      | SReturn e -> ignore(match fdecl.styp with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder 
                              (* Build return statement *)
                            | _ -> L.build_ret (expr builder e) builder );
                     builder
      | SIf (predicate, then_stmt, else_stmt) ->
         let bool_val = expr builder predicate in
	       let merge_bb = L.append_block context "merge" the_function in
         let build_br_merge = L.build_br merge_bb in (* partial function *)

	 let then_bb = L.append_block context "then" the_function in
	 add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
	   build_br_merge;

	 let else_bb = L.append_block context "else" the_function in
	 add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
	   build_br_merge;

	 ignore(L.build_cond_br bool_val then_bb else_bb builder);
	 L.builder_at_end context merge_bb

      | SWhile (predicate, body) ->
	  let pred_bb = L.append_block context "while" the_function in
	  ignore(L.build_br pred_bb builder);

	  let body_bb = L.append_block context "while_body" the_function in
	  add_terminal (stmt (L.builder_at_end context body_bb) body)
	    (L.build_br pred_bb);

	  let pred_builder = L.builder_at_end context pred_bb in
	  let bool_val = expr pred_builder predicate in

	  let merge_bb = L.append_block context "merge" the_function in
	  ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
	  L.builder_at_end context merge_bb

      (* Implement for loops as while loops *)
      | SFor (e1, e2, e3, body) -> stmt builder
	    ( SBlock [SExpr e1 ; SWhile (e2, SBlock [body ; SExpr e3]) ] )
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (SBlock fdecl.sbody) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.styp with
        A.Void -> L.build_ret_void
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body functions;
  the_module
