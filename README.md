### Before doing anything, run the line below if necessary

```
eval $(opam env)
```

### Build the Integraph compiler

```
ocamlbuild -pkgs llvm integraph.native
```

### Run the InteGraph compiler and generate llvm code for a file called example.mc containing InteGraph source code
```
./integraph.native -l example.mc > example.out
```

### Run the llvm code generated from the previous stem
```
lli example.out
```

### Run the automated tests (assuming that "eval $(opam env)" and "ocamlbuild -pkgs llvm integraph.native" have been run)
```
python3 automatedTests.py
```

### Compiler files
-  `ast.ml`: abstract syntax tree (AST) definition
-  `scanner.mll`: scanner
-  `microcparse.mly`: parser
-  `sast.ml`: definition of the semantically-checked AST
-  `semant.ml`: semantic checking
-  `codegen.ml`: LLVM IR code generator

### Other files

- `testAST.ml`: the file to test the scanner and parser
- `testSemant.ml`: the file to test the semantic checker
- `integraph.ml`: top-level file to test and run the integraph compiler
- `example.mc`: a sample microc source code
- `example.out`: a sample compiled code of example.mc
