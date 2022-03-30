### Build the MicroC compiler

```
ocamlbuild test2.native
```

### Run the MicroC compiler and generate llvm code
```
./test2.native
```

### Compiler files
-  `ast.ml`: abstract syntax tree (AST) definition
-  `scanner.mll`: scanner
-  `microcparse.mly`: parser
-  `sast.ml`: definition of the semantically-checked AST
-  `semant.ml`: semantic checking

### Other files

- `test1.ml`: the file to test the scanner and parser
- `test2.ml`: the file to test the semantic checker
- `example.mc`: a sample microc source code
- `example.out`: a sample checked code of example.mc
