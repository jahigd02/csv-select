#!/bin/bash

flex --header-file=lex.yy.h ./select.l 
bison -d ./select.y
flex --header-file=lex.yy.h ./select.l 
gcc -pg -o select driver.c select.tab.c lex.yy.c -lfl
time ./select $1
./purge.sh