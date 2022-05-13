### Before doing anything, run the line below if necessary

```
eval $(opam env)
```

### Build the Integraph compiler

```
ocamlbuild -pkgs llvm integraph.native
```

### Run the MicroC compiler and generate llvm code
```
./integraph.native -l example.mc > example.out
```

### Run the llvm code
```
lli example.out
```

### Compiler files
-  `ast.ml`: abstract syntax tree (AST) definition
-  `scanner.mll`: scanner
-  `parser.mly`: parser
-  `sast.ml`: definition of the semantically-checked AST
-  `semant.ml`: semantic checking
-  `codegen.ml`: LLVM IR code generator

### Other files

- `test.ml`: the file to test the scanner and parser
- `testsemantics.ml`: the file to test the semantic checker
- `integraph.ml`: top-level file to test and run integraph compiler
- `example.mc`: a sample microc source code
- `example.out`: a sample compiled code of example.mc
