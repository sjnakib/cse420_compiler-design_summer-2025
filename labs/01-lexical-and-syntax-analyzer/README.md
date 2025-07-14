# Lab 01: Lexical and Syntax Analyzer

## What it does

This lab reads a small C program and runs a Flex lexer and a Bison parser. The lexer finds keywords, identifiers, constants, operators and punctuation. The parser checks the grammar and writes each token and grammar rule to a log file.

## Files

- `src/24241257.l`: Flex lexer
- `src/24241257.y`: Bison parser
- `src/symbol_info.h`: small class used for token values
- `src/script.sh` and `src/script.bat`: build and run scripts
- `samples/input.txt`: test program
- `samples/output.txt`: output from the test program
- `docs/lab-01-spec.pdf`: task sheet
- `../../course-docs/c-syntax-analyzer-grammar.pdf`: C grammar used in the lab

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
./analyzer ../samples/input.txt
```

The program writes `24241257_log.txt` in the folder where you run it.

## Sample output

```text
Line no 1: Token <INT> Lexeme int found

At line no: 1 type_specifier : INT

int

Line no 1: Token <ID> Lexeme x found
```

The log ends with:

```text
At line no: 21 start : program

Total lines: 21
```

## Known limits

- The grammar covers a subset of C. It does not support pointers, structs or multidimensional arrays.
- This lab stops after syntax analysis. It does not build a symbol table or run semantic checks.
- The output is a parse trace, not an executable compiler.
