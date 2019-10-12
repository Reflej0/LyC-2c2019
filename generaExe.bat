del ts.txt
flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe lex.yy.c y.tab.c -o Primera.exe
pause
pause
Primera.exe Prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe
pause