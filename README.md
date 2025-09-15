# CSE420 Compiler Design, Summer 2025

![Stars](https://img.shields.io/github/stars/sjnakib/cse420_compiler-design_summer-2025?style=for-the-badge&logo=github&color=yellow)
![Last Commit](https://img.shields.io/github/last-commit/sjnakib/cse420_compiler-design_summer-2025?style=for-the-badge&color=blue)
![Repo Size](https://img.shields.io/github/repo-size/sjnakib/cse420_compiler-design_summer-2025?style=for-the-badge&color=green)
![Top Language](https://img.shields.io/github/languages/top/sjnakib/cse420_compiler-design_summer-2025?style=for-the-badge)

![C++](https://img.shields.io/badge/C%2B%2B-00599C?style=for-the-badge&logo=cplusplus&logoColor=white)
![Flex](https://img.shields.io/badge/Flex-2.6.4-blue?style=for-the-badge)
![Bison](https://img.shields.io/badge/Bison-3.8.2-green?style=for-the-badge)
![BRAC University](https://img.shields.io/badge/BRAC_University-CSE420-blueviolet?style=for-the-badge)

This repo has my lab submissions and theory work for CSE420 Compiler Design at BRAC University, Summer 2025. The labs build a small compiler front end for a subset of C. They cover lexical analysis, syntax analysis, symbol tables and semantic checks. The theory folder has the written assignments.

## 📚 Assignments

| # | Work | What it does | Tools | Folder |
|---|------|--------------|-------|--------|
| 1 | Lab 01, Lexical and Syntax Analyzer | Reads a C program, finds tokens and checks the grammar | Flex, Bison, C++ | [Open](labs/01-lexical-and-syntax-analyzer/) |
| 2 | Lab 02, Symbol Table | Adds scoped hash tables and stores variables, arrays and functions | C++, Flex, Bison | [Open](labs/02-symbol-table/) |
| 3 | Lab 03, Semantic Analysis | Checks types, arrays, function calls and duplicate names | C++, Flex, Bison | [Open](labs/03-semantic-analysis/) |
| 4 | Theory 01, RE to DFA | Task sheet for the direct regular expression to DFA construction | PDF | [Open](theory/01-re-to-dfa/) |
| 5 | Theory 02, CLR(1) Parser | Handwritten CLR(1) automaton submission | PDF | [Open](theory/02-clr-parser/) |
| 6 | Theory 03, Three-Address Code | Attribute grammar and SDT rules for declarations and code generation | PDF, DOCX | [Open](theory/03-three-address-code/) |

## 📁 Project Structure

```text
.
├── course-docs/          # syllabus, lab policy, class notes and shared grammar sheet
├── labs/
│   ├── 01-lexical-and-syntax-analyzer/
│   ├── 02-symbol-table/
│   └── 03-semantic-analysis/
└── theory/
    ├── 01-re-to-dfa/
    ├── 02-clr-parser/
    └── 03-three-address-code/
```

Each assignment folder has its own README, source or submission file, task sheet and sample data where it applies.

## ▶️ How to Run

You need `bison`, `flex` and `g++`.

On Debian or Ubuntu:

```bash
sudo apt install flex bison g++
```

On Windows, install MSYS2 or MinGW with `flex`, `bison` and `g++`, then add its `bin` folder to `PATH`. You can also run the `.sh` scripts from Git Bash.

Go to a lab's `src` folder and run its script.

Linux, macOS or Git Bash:

```bash
cd labs/01-lexical-and-syntax-analyzer/src
./script.sh
```

Windows Command Prompt:

```bat
cd labs\01-lexical-and-syntax-analyzer\src
script.bat
```

Change `01-lexical-and-syntax-analyzer` to `02-symbol-table` or `03-semantic-analysis` for the other labs. The scripts read the input from `../samples` and write their logs in the `src` folder. Each lab README has the manual build commands and the output file names.

The code was tested on Linux with Flex 2.6.4, Bison 3.8.2 and GCC 16.2.1.

## 🛠️ Skills Shown

- Writing regular expressions and a Flex lexer for a C subset
- Writing a Bison grammar and building a parser
- Printing tokens, grammar rules and parse steps
- Building a scoped symbol table with hashing
- Handling nested scopes and function parameters
- Type checking, array checks and duplicate declaration checks
- Reading and writing syntax-directed translation rules
- Working with C++ classes and data structures

## 👤 Author

**Shafaat Jamil Nakib**

[github.com/sjnakib](https://github.com/sjnakib)
