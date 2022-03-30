### Build the NanoC scanner

```
ocamlbuild test.native
```

### Run the NanoC scanner
```
./test.native
```

### Compiler files
-  `ast.ml`: abstract syntax tree (AST)--a list of strings for NanoC scanner
-  `scanner.mll`: scanner
-  `nanocparse.mly`: parser--parse the sequence of tokens into a list of strings

### Other files

- `test.ml`: top-level file to test and run the scanner
- `example.mc`: a sample NanoC source code
- `example.out`: a sample scanned code of example.mc
