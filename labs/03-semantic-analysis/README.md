# Lab 03: Semantic Analysis

## What it does

This lab adds semantic checks to the parser and symbol table from Lab 02. It checks assignment types, array indexes, modulus and division rules, function arguments and return types. It also finds undeclared names, duplicate declarations in the same scope and void values used in expressions. Errors are collected in a separate file while the parser keeps going.

## Files

- `src/24241257.l`: Flex lexer
- `src/24241257.y`: Bison parser with type checks
- `src/symbol_info.h`: symbol data with type and parameter details
- `src/scope_table.h`: one hash table for one scope
- `src/symbol_table.h`: stack of scope tables
- `src/script.sh` and `src/script.bat`: build and run scripts
- `samples/input.c`: test program with many errors
- `samples/output.txt`: parser log from the test program
- `samples/errors.txt`: error log from the test program
- `docs/lab-03-spec.pdf`: task sheet

## How to run

Linux, macOS or Git Bash:

```bash
cd src
./script.sh
```

Windows Command Prompt:

```bat
cd src
script.bat
```

Manual build:

```bash
cd src
bison -d -y 24241257.y
flex 24241257.l
g++ -w -c -o y.o y.tab.c
g++ -fpermissive -w -c -o l.o lex.yy.c
g++ y.o l.o -o analyzer
./analyzer ../samples/input.c
```

The program writes `24241257_log.txt` and `24241257_error.txt` in the folder where you run it.

## Sample output

The sample input is an error test. It reports 19 errors, including:

```text
At line no: 16 Multiple declaration of variable a in parameter of foo2

At line no: 41 argument 1 type mismatch in function call: func

At line no: 49 array index is not of integer type : c

At line no: 55 Modulus by 0
```

The error file ends with:

```text
Total errors: 19
```

## Known limits

- The parser covers a subset of C and does not support pointers, structs or multidimensional arrays.
- This lab stops after semantic analysis. It does not generate three-address code.
- The sample input is meant to fail. A clean program should produce no error lines.
