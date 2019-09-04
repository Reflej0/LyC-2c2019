%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

FILE *yyin;
char *yytext;
extern int yylineno;
char tipoActual[10]={""};
char listaVariables[10][20]={""};
int variableActual=0;
void reinicioVariables();

%}

%union {
int intVal;
double realVal;
char *strVal;
}

%token <strVal>ID <intVal>CTE_INT <strVal>CTE_STRING <realVal>CTE_REAL
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

%start start

%%

start: programa { printf("\n\n\tCOMPILACION EXITOSA!!\n\n\n"); }
	 |			{ printf("\n El archivo 'Prueba.Txt' no tiene un programa\n"); }
	 ;

programa: declaracion { printf("Declaracion OK\n"); } bloque
        | bloque
		;
		
declaracion: VAR def_variables ENDVAR
		   | VAR ENDVAR
		   ;
		   
def_variables: def_variables def_var { printf("\n sint: def variables\n"); };
				| def_var;	   
		   
def_var: tipo DOS_PUNTOS listavar{ guardarTipos(variableActual, listaVariables, tipoActual); reinicioVariables(); }  
         ;

listavar: listavar PUNTO_COMA ID { strcpy(listaVariables[variableActual++],$3); insertar_id_en_ts($3); }
	    | ID { strcpy(listaVariables[variableActual++],$1); insertar_id_en_ts($1); } 
        ;
	
tipo: INT    { strcpy(tipoActual,"INT"); }
    | FLOAT  { strcpy(tipoActual,"REAL"); }
	| STRING { strcpy(tipoActual,"STRING"); }
	;
		
bloque: sentencia
	  | bloque sentencia
	  ;
		
sentencia: asignacion PUNTO_COMA	{ printf("Asignacion OK\n"); }
		 | iteracion  				{ printf("Iteracion OK\n"); }
		 | decision   				{ printf("Decision OK\n"); }
		 | entrada PUNTO_COMA   	{ printf("Entrada OK\n"); }
		 | salida PUNTO_COMA    	{ printf("Salida OK\n"); }
		 | asignacion_constante PUNTO_COMA 	{ printf("Constante con nombre OK\n"); }
		 ;
		 
asignacion: ID ASIG expresion
		  ;

asignacion_constante: CONST ID ASIG constante {existe_cte_en_ts($2);}
		;

iteracion: REPEAT bloque UNTIL P_A condicion P_C
		 ;
		
decision: IF P_A condicion P_C bloque ELSE bloque ENDIF
		| IF P_A condicion P_C bloque ENDIF
		;

condicion: comparacion
         | comparacion AND comparacion 
		 | comparacion OR comparacion
		 | NOT comparacion
		 | NOT P_A comparacion P_C
		 ;

comparacion: expresion MENOR expresion       { printf("Condicion menor OK\n"); }
		   | expresion MENOR_IGUAL expresion { printf("Condicion menor o igual OK\n"); }
		   | expresion MAYOR expresion       { printf("Condicion mayor OK\n"); }
		   | expresion MAYOR_IGUAL expresion { printf("Condicion mayor o igual OK\n"); }
		   | expresion IGUAL expresion       { printf("Condicion igual OK\n"); }
		   | expresion DISTINTO expresion    { printf("Condicion distinto OK\n"); }                   
		   ; 

condicion_filter: comparacion_filter
         | comparacion_filter AND comparacion_filter 
		 | comparacion_filter OR comparacion_filter
		 | NOT comparacion_filter
		 | NOT P_A comparacion_filter P_C
		 ;

comparacion_filter: GUION_BAJO MENOR expresion       { printf("Filter Condicion menor OK\n"); }
		   | GUION_BAJO MENOR_IGUAL expresion { printf("Filter Condicion menor o igual OK\n"); }
		   | GUION_BAJO MAYOR expresion       { printf("Filter Condicion mayor OK\n"); }
		   | GUION_BAJO MAYOR_IGUAL expresion { printf("Filter Condicion mayor o igual OK\n"); }
		   | GUION_BAJO IGUAL expresion       { printf("Filter Condicion igual OK\n"); }
		   | GUION_BAJO DISTINTO expresion    { printf("Filter Condicion distinto OK\n"); }                   
		   ; 

filter: FILTER P_A condicion_filter COMA C_A filterlist C_C P_C

filterlist: filterlist COMA ID
			| ID
			;
		  
expresion: expresion OP_SUMA termino  { printf("Suma OK\n"); }
		 | expresion OP_RESTA termino { printf("Resta OK\n"); }
		 | termino
		 ;
		 
termino: termino OP_MULT factor { printf("Multiplicacion OK\n"); }
	   | termino OP_DIV factor	{ printf("Division OK\n"); }
	   | factor
	   ;
	   
factor: ID	              { existe_en_ts($1); printf("ID es: %s\n",yylval.strVal); }  
	  | constante
	  | P_A expresion P_C
	  | filter 			  { printf("filter OK\n"); }
	  ;
	  
constante: CTE_INT    { printf("ENTERO es: %d\n",yylval.intVal); }  
         | CTE_STRING { printf("STRING es: %s\n",yylval.strVal); }  
		 | CTE_REAL   { printf("REAL es: %.2f\n",yylval.realVal); }
		 ;

entrada: READ ID
       ;
	   
salida: PRINT CTE_STRING
      | PRINT ID 			{ existe_en_ts($2); }
	  ;
	  
%%

int main(int argc,char *argv[])
{
  
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
	//mostrar_ts();
	save_reg_ts();
	printf("Listo TS\n");
  }
  fclose(yyin);
  return 0;
}

int yyerror(char *errMessage)
{
   printf("(!) ERROR en la linea %d: %s\n",yylineno,errMessage);
   fprintf(stderr, "Fin de ejecucion.\n");
   system ("Pause");
   exit (1);
}

void reinicioVariables() {
	variableActual=0;
    strcpy(tipoActual,"");
}


