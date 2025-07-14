#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

input="${1:-../samples/input.txt}"

rm -f y.tab.c y.tab.h y.output lex.yy.c y.o l.o analyzer analyzer.exe 24241257_log.txt

bison -d -y 24241257.y
flex 24241257.l
g++ -w -c -o y.o y.tab.c
g++ -fpermissive -w -c -o l.o lex.yy.c
g++ y.o l.o -o analyzer

./analyzer "$input"

printf '\nLog file: %s\n' "$(pwd)/24241257_log.txt"
