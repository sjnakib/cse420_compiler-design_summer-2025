# Lab 02: Symbol Table

## What it does

This lab adds a symbol table to the parser from Lab 01. The table is a stack of scope tables. Each scope table is a hash table. When the parser enters a block or function, it creates a new scope. When it leaves, it prints the scope and removes it. The table stores variables, arrays, functions and function parameters.

## Files

- `src/24241257.l`: Flex lexer
- `src/24241257.y`: Bison parser with symbol table actions
- `src/symbol_info.h`: symbol data
- `src/scope_table.h`: one hash table for one scope
- `src/symbol_table.h`: stack of scope tables
- `src/script.sh` and `src/script.bat`: build and run scripts
- `samples/input.c`: test program
- `samples/output.txt`: output from the test program
- `docs/lab-02-spec.pdf`: task sheet
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
./analyzer ../samples/input.c
```

The submitted source writes its log to `log.txt` in the folder where you run it.

## Sample output

```text
New ScopeTable with ID 1 created

At line no: 1 type_specifier : INT

int
```

The final symbol table prints entries like:

```text
< func : ID >
Function Definition
Return Type : int
Number of Parameters: 2
Parameter Details: int a, int b
```

## Known limits

- This lab stores symbols and scopes. It does not check types or report semantic errors.
- The log file is named `log.txt`, not `<student_id>_log.txt` as the task sheet asks. The submitted source is unchanged.
- The grammar still covers only a subset of C.
