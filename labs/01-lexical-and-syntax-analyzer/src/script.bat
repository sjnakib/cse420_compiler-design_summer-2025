@echo off
setlocal
cd /d "%~dp0"

set "INPUT=%~1"
if "%INPUT%"=="" set "INPUT=..\samples\input.txt"

del /q y.tab.c y.tab.h y.output lex.yy.c y.o l.o analyzer.exe 24241257_log.txt 2>nul

bison -d -y 24241257.y
if errorlevel 1 exit /b 1
flex 24241257.l
if errorlevel 1 exit /b 1
g++ -w -c -o y.o y.tab.c
if errorlevel 1 exit /b 1
g++ -fpermissive -w -c -o l.o lex.yy.c
if errorlevel 1 exit /b 1
g++ y.o l.o -o analyzer.exe
if errorlevel 1 exit /b 1

analyzer.exe "%INPUT%"
if errorlevel 1 exit /b 1

echo.
echo Log file: %CD%\24241257_log.txt
