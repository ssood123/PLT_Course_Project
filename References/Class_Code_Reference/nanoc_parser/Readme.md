### Build the NanoC parser

```
ocamlbuild test.native
```

### Run the NanoC parser
```
./test.native
```

### Compiler files
-  `ast.ml`: abstract syntax tree (AST)
-  `scanner.mll`: scanner
-  `nanocparse.mly`: parser

### Other files

- `test.ml`: top-level file to test and run the scanner
- `example.mc`: a sample NanoC source code
- `example.out`: a sample parsed code of example.mc
