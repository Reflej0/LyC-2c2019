%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol.h"
#include <string.h>

#define YYDEBUG 1
extern int yylex();
extern int yyparse();
extern yylineno;
extern FILE* yyin;

int tipos_variables = 0;
int variables = 0;
%}

%token ID CTE_INT CTE_STRING CTE_REAL
%token ASIG OP_SUMA OP_RESTA OP_MULT OP_DIV
%token MENOR MAYOR IGUAL DISTINTO MENOR_IGUAL MAYOR_IGUAL
%token CONST
%token FILTER
%token REPEAT UNTIL
%token IF ELSE ENDIF
%token P_A P_C C_A C_C
%token GUION_BAJO
%token COMA PUNTO_COMA DOS_PUNTOS
%token AND OR NOT
%token INT FLOAT STRING 
%token VAR ENDVAR
%token PRINT READ
%left OP_SUMA
%left OP_RESTA
%left OP_DIV
%left OP_MULT
%left IGUAL
%left DISTINTO
%left MAYOR
%left MAYOR_IGUAL
%left MENOR
%left MENOR_IGUAL
%left OR
%left AND
%start programa
%type <intVal> CTE_INT
%type <floatVal> CTE_REAL
%type <strVal> CTE_STRING
%type <strVal> ID
%type <auxLogicOperator> logic_operator
%type <auxLogicOperator> logic_concatenator

%union 
{
  int intVal;
  float floatVal;
  char strVal[30];
  char* auxLogicOperator;
}

%%


programa: sentencia_declaracion {printf("\n Regla: COMPILACION EXITOSA\n");}
  ;

sentencia_declaracion: bloque_declaracion_variables bloque {printf("\n Regla: sentencia: bloque_declaracion_variables bloque \n");}
  | bloque_declaracion_variables {printf("\n Regla: sentencia: bloque_declaracion_variables \n");}
  ;

bloque_declaracion_variables: VAR declaracion_variables ENDVAR {printf("\n Regla: bloque_declaracion_variables: VAR declaracion_variables ENDVAR \n");}
  ;

declaracion_variables: declaracion_variables declaracion_variable {printf("\n Regla: declaracion_variables: declaracion_variables declaracion_variable \n");}
  | declaracion_variable {printf("\n Regla: declaracion_variables: declaracion_variable \n");}

declaracion_variable: C_A lista_tipos_variable C_C DOS_PUNTOS C_A lista_variables C_C {printf("\n Regla: declaracion_variable: C_A lista_tipo_variable C_C DOS_PUNTOS C_A lista_variables C_C\n"); 
	if(tipos_variables>variables){/*Mas tipos que variables*/}
	else if(tipos_variables<variables){/*Mas variables que tipos*/}}
  ;

lista_tipos_variable: lista_tipos_variable COMA tipo_variable {printf("\n lista_tipos_variable: lista_tipos_variable COMA tipo_variable \n"); tipos_variables++;}
  | tipo_variable {printf("\n lista_tipos_variable: tipo_variable \n"); tipos_variables++;};

tipo_variable: INT {printf("\n Regla: tipo_variable: INT \n");}
  | FLOAT {printf("\n Regla: tipo_variable: FLOAT \n");}
  | STRING {printf("\n Regla: tipo_variable: STRING \n");}
  ;
lista_variables: lista_variables COMA ID {printf("\n Regla: lista_variables: lista_variables COMA ID \n"); variables++;} 
  | ID {printf("\n Regla: lista_variables: ID \n"); variables++;}
  ;

bloque: sentencia {printf("\n Regla: bloque: sentencia \n");}
  | bloque sentencia {printf("\n Regla: bloque: bloque sentencia \n");}
  ;

sentencia: decision {printf("\n Regla: sentencia: decision \n");}
  | asignacion {printf("\n Regla: sentencia: asignacion \n");}
  | print {printf("\n Regla: sentencia: print \n");}
  | read {printf("\n Regla: sentencia: read \n");}
  | iteracion {printf("\n Regla: sentencia: iteracion \n");}
  | asignacion_constante  {printf("Regla: asignacion_constante OK\n");}
  ;

decision: IF P_A condicion P_C bloque ELSE bloque ENDIF {printf("\n Regla: decision: IF P_A condicion P_C bloque ELSE bloque ENDIF \n");}
  | IF P_A condicion P_C bloque ENDIF {printf("\n Regla: decision: IF P_A condicion P_C bloque ENDIF \n");}
  ;

asignacion: ID ASIG expresion {printf("\n Regla: asignacion: ID ASIG expresion \n");};

asignacion_constante: CONST ID ASIG expresion {printf("\n Regla: asignacion_constante: CONST ID ASIG expresion \n");};

iteracion: REPEAT bloque UNTIL P_A condicion P_C {printf("\n Regla: iteracion: REPEAT bloque UNTIL P_A condicion P_C \n");};

condicion_filter: comparacion_filter { printf("\n Regla: condicion_filter: comparacion_filter \n");}
  | comparacion_filter logic_concatenator comparacion_filter {printf("\n Regla: condicion_filter: comparacion_filter logic_concatenator comparacion_filter \n");}
  | NOT P_A comparacion_filter P_C {printf("\n Regla: condicion_filter: NOT comparacion_filter \n");}
  ;

comparacion_filter: GUION_BAJO logic_operator  expresion {printf("\n Regla: comparacion_filter: expresion  logic_operator  expresion \n");}
  ;

filter: FILTER P_A condicion_filter COMA C_A filterlist C_C P_C {printf("\n Regla: filter: FILTER P_A condicion_filter COMA C_A filterlist C_C P_C \n");}
  ;

filterlist: filterlist COMA ID {printf("\n Regla: filterlist: filterlist COMA ID \n");}
      | ID {printf("\n Regla: filterlist: ID \n");}
      ;

print: PRINT ID {printf("\n Regla: print: PRINT ID \n");}
  | PRINT CTE_INT {printf("\n Regla: print: PRINT CTE_INT \n");}
  | PRINT CTE_REAL {printf("\n Regla: print: PRINT CTE_REAL \n");}
  | PRINT CTE_STRING {printf("\n Regla: print: PRINT CTE_STRING \n");}
  ;

read: READ ID {printf("\n Regla: read: READ ID \n");};

condicion: comparacion {printf("\n Regla: condicion: comparacion \n");}
  | comparacion logic_concatenator comparacion {printf("\n Regla: condicion: comparacion logic_concatenator comparacion \n");}
  | NOT P_A comparacion P_C {printf("\n Regla: condicion: NOT comparacion \n");}
  ;

comparacion: expresion  logic_operator  expresion {printf("\n Regla: comparacion: expresion  logic_operator  expresion \n");}
  ;

logic_operator: IGUAL {printf("\n Regla: logic_operator: IGUAL \n");}
  | DISTINTO {printf("\n Regla: logic_operator: DISTINTO \n");}
  | MAYOR {printf("\n Regla: logic_operator: MAYOR \n");}
  | MAYOR_IGUAL {printf("\n Regla: logic_operator: MAYOR_IGUAL \n");}
  | MENOR {printf("\n Regla: logic_operator: MENOR \n");}
  | MENOR_IGUAL {printf("\n Regla: logic_operator: MENOR_IGUAL \n");}
  ;

logic_concatenator: OR {printf("\n Regla: logic_concatenator: OR \n");}
  | AND {printf("\n Regla: logic_concatenator: AND \n");}
  ;

expresion: expresion OP_SUMA termino {printf("\n Regla: expresion: expresion OP_SUMA termino\n");}
  | expresion OP_RESTA termino { printf("\n Regla: expresion: expresion OP_RESTA termino\n");}
  | termino {printf("\n Regla: expresion: termino\n");}
  ;

termino: termino OP_MULT factor {printf("\n Regla: termino: termino OP_MULT factor\n");}
  | termino OP_DIV factor {printf("\n Regla: termino: termino OP_DIV factor\n");}
  | factor {printf("\n Regla: termino: factor\n");}
  ;

factor: ID {printf("\n Regla: factor: ID \n");}
  | CTE_INT {printf("\n Regla: factor: CTE_INT \n");}
  | CTE_REAL { printf("\n Regla: factor: CTE_REAL \n");}
  | CTE_STRING {printf("\n Regla: factor: CTE_STRING \n");}
  | P_A expresion P_C {printf("\n Regla: factor: P_A expresion P_C \n");}
  | filter { printf("filter OK\n"); }
  ;


%%

int main(int argc, char *argv[]) 
{
	yyin = fopen(argv[1], "r");
  yydebug = 0;
  printf("COMENZANDO COMPILACION\n");
  symbolTable = NULL;
	do 
  {
		yyparse();
	} 
  while(!feof(yyin));
  printTable();
  saveTable();
	return 0;
}


