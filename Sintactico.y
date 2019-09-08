%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"
#include "arbol.h"

#define YYDEBUG 1
extern int yylex();
extern int yyparse();
extern yylineno;
extern FILE* yyin;
void yyerror(const char* s);
void guardarTipoDeclaracion();
char tipoDeclaracionIDActual[7];
void validarDeclaracionIDs();
void compararIdentificadores();
void validarDeclaracionID();
void validarTipo();
void validarAsignacion();

char* recorrido[200];
int indiceRecorrido = 0;
ast* tree;
%}

%union 
{
	int intVal;
	double realVal;
	char strVal[30];
	struct NodoArbol* ast;
	char* operadorLogicoAuxiliar
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

%left OP_SUMA
%left OP_RESTA
%left OP_DIV
%left OP_MULT
%left IGUAL
%left DISTINTO
%left NOT_LOGIC_OPERATOR
%left MAYOR
%left MAYOR_IGUAL
%left MENOR
%left MENOR_IGUAL
%left OR
%left AND

%start start

%type <ast> start
%type <ast> programa
%type <ast> tipo
%type <ast> bloque
%type <ast> sentencia
%type <ast> asignacion
%type <ast> asignacion_constante
%type <ast> condicion
%type <ast> decision
%type <ast> comparacion
%type <ast> expresion
%type <ast> iteracion
%type <ast> termino
%type <ast> factor
%type <ast> salida
%type <ast> entrada
%type <ast> constante
%type <ast> ASIG
%type <intVal> INT
%type <relVal> FLOAT
%type <strVal> STRING
%type <strVal> CONST
%%

start: programa { printf("\n Regla: Compilacion Exitosa\n"); $$ = $1; tree = $$;}
	 |			{ printf("\n El archivo 'Prueba.Txt' no tiene un programa\n"); }
	 ;

programa: declaracion bloque { printf("\n Regla: programa: declaracion bloque \n"); $$ = $2;}
        | bloque {printf("\n Regla: programa: bloque \n");}
		;
		
declaracion: VAR def_variables ENDVAR { printf("\n Regla: declaracion: VAR def_variables ENDVAR \n");}
		   | VAR ENDVAR
		   ;
		   
def_variables: def_variables def_var { printf("\n Regla: def_variables: def_variables def_var \n");}
				| def_var {printf("\n Regla: def_variables: def_var \n");};	   
		   
def_var: tipo DOS_PUNTOS listavar { /*insertarIdentificadorEnTS(tipoDeclaracionIDActual);*/ printf("\n Regla: def_var: tipo DOS_PUNTOS listavar\n");}
         ;

listavar: listavar PUNTO_COMA ID { validarDeclaracionID($3); insertar_id_en_ts($3); printf("\n Regla: listavar: listavar PUNTO_COMA ID \n");} 
	    | ID { validarDeclaracionID($1); insertar_id_en_ts($1); printf("\n Regla: listavar: ID \n");}
        ;
	
tipo: INT    { guardarTipoDeclaracion($1); printf("\n Regla: tipo: INT \n");}
    | FLOAT  { guardarTipoDeclaracion($1); printf("\n Regla: tipo: FLOAT \n");}
	| STRING { guardarTipoDeclaracion($1); printf("\n Regla: tipo: STRING \n");}
	;
		
bloque: sentencia {$$ = $1; printf("\n Regla: bloque: sentencia \n");}
	  | bloque sentencia {$$ = CrearNodo("BLOQUE", $1, $2); printf("\n Regla: bloque: bloque sentencia \n");}
	  ;
		
sentencia: asignacion PUNTO_COMA	{ printf("\n Regla: sentencia: asignacion \n"); $$ = $1;}
		 | iteracion  				{ printf("\n Regla: sentencia: iteracion \n"); $$ = $1;}
		 | decision   				{ printf("\n Regla: sentencia: decision \n"); $$ = $1;}
		 | entrada PUNTO_COMA   	{ printf("\n Regla: sentencia: entrada \n"); $$ = $1;}
		 | salida PUNTO_COMA    	{ printf("\n Regla: sentencia: salida \n"); $$ = $1;}
		 | asignacion_constante PUNTO_COMA 	{ printf("\n Regla: sentencia: asignacion_constante \n"); $$ = $1;}
		 ;
		 
asignacion: ID ASIG expresion {validarAsignacion($1, $3);validarDeclaracionIDs($1); $$ = CrearNodo("=", CrearHoja($1), $3); printf("\n Regla: asignacion: ID ASIG expression \n");};
		  ;

asignacion_constante: CONST ID ASIG constante {validarDeclaracionIDs($1); $$ = CrearNodo("=", CrearHoja($1), $3); printf("\n Regla: asignacion: ID ASIG expression \n");};
		;

iteracion: REPEAT bloque UNTIL P_A condicion P_C
		 ;
		
decision: IF P_A condicion P_C bloque ELSE bloque ENDIF
		| IF P_A condicion P_C bloque ENDIF {$$ = CrearNodo("IF", $3, $5); printf("\n Regla: decision: IF P_A condicion P_C bloque ENDIF \n");};
		;

condicion: comparacion {$$ = $1; printf("\n Regla: condicion: comparacion \n");}
         | comparacion AND comparacion  {$$ = CrearNodo("AND", $1, $3); printf("\n Regla: condicion: comparacion AND comparacion \n");}
		 | comparacion OR comparacion {$$ = CrearNodo("OR", $1, $3); printf("\n Regla: condicion: comparacion OR comparacion \n");}
		 | NOT comparacion {$$ = CrearNodo("!", $2, NULL); printf("\n Regla: condicion: NOT comparacion \n");}
		 | NOT P_A comparacion P_C {$$ = CrearNodo("!", $3, NULL); printf("\n Regla: condicion: NOT comparacion \n");}
		 ;

comparacion: expresion MENOR expresion       { validarTipo($1, $3, 1); $$ = CrearNodo("<", $1, $3); printf("\n Regla: comparacion: expresion  MENOR  expresion \n");}
		   | expresion MENOR_IGUAL expresion { validarTipo($1, $3, 1); $$ = CrearNodo("<=", $1, $3); printf("\n Regla: comparacion: expresion  MENOR_IGUAL  expresion \n");}
		   | expresion MAYOR expresion       { validarTipo($1, $3, 1); $$ = CrearNodo(">", $1, $3); printf("\n Regla: comparacion: expresion  MAYOR  expresion \n");}
		   | expresion MAYOR_IGUAL expresion { validarTipo($1, $3, 1); $$ = CrearNodo(">=", $1, $3); printf("\n Regla: comparacion: expresion  MAYOR_IGUAL  expresion \n");}
		   | expresion IGUAL expresion       { validarTipo($1, $3, 1); $$ = CrearNodo("==", $1, $3); printf("\n Regla: comparacion: expresion  IGUAL  expresion \n");}
		   | expresion DISTINTO expresion    { validarTipo($1, $3, 1); $$ = CrearNodo("!=", $1, $3); printf("\n Regla: comparacion: expresion  DISTINTO  expresion \n");}
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
		  
expresion: expresion OP_SUMA termino  { validarTipo($1, $3, 1); $$ = CrearNodo("+", $1, $3); printf("\n Regla: expresion: expresion OP_SUMA termino\n");}
		 | expresion OP_RESTA termino { validarTipo($1, $3, 1); $$ = CrearNodo("-", $1, $3); printf("\n Regla: expresion: expresion OP_RESTA termino\n");}
		 | termino {$$ = $1; printf("\n Regla: expresion: termino\n");}
		 ;
	 
termino: termino OP_MULT factor { validarTipo($1, $3, 1); $$ = CrearNodo("*", $1, $3); printf("\n Regla: termino: termino OP_MULT factor\n"); }
	   | termino OP_DIV factor	{ validarTipo($1, $3, 1); $$ = CrearNodo("/", $1, $3); printf("\n Regla: termino: termino OP_DIV factor\n"); }
	   | factor {$$ = $1; printf("\n Regla: termino: factor\n");}
	   ;
	   
factor: ID	              { $$ = CrearHoja($1); printf("\n Regla: factor: ID \n"); }  
	  | constante
	  | P_A expresion P_C { $$ = $2; printf("\n Regla: factor: P_A expresion P_C \n"); }
	  | filter 			  { printf("filter OK\n"); }
	  ;
	  
constante: CTE_INT    { $$ = CrearHoja( getNombreSimbolo(&($1),1)); printf("\n Regla: factor: CTE_INT \n"); }  
         | CTE_STRING { $$ = CrearHoja( getNombreSimbolo($1,3)); printf("\n Regla: factor: CTE_STRING \n"); }  
		 | CTE_REAL   { $$ = CrearHoja( getNombreSimbolo(&($1),2)); printf("\n Regla: factor: CTE_REAL \n");}
		 ;

entrada: READ ID {$$ = CrearNodo("READ", CrearHoja($2), NULL); printf("\n Regla: entrada: READ ID \n");};
       ;
	   
salida: PRINT ID 			{ validarDeclaracionIDs($2); $$ = CrearNodo("PRINT", CrearHoja($2), NULL); printf("\n Regla: salida: PRINT ID \n");}
      | PRINT CTE_REAL		{$$ = CrearNodo("PRINT",CrearHoja(getNombreSimbolo(&($2),2)), NULL); printf("\n Regla: salida: PRINT CTE_REAL \n");}
      | PRINT CTE_INT 		{$$ = CrearNodo("PRINT",CrearHoja(getNombreSimbolo(&($2),1)), NULL); printf("\n Regla: salida: PRINT CTE_INT \n");}
      | PRINT CTE_STRING	{$$ = CrearNodo("PRINT",CrearHoja(getNombreSimbolo(&($2),3)), NULL); printf("\n Regla: salida: PRINT CTE_STRING \n");}
	  ;
	  
%%

int main(int argc, char *argv[]) 
{
	yyin = fopen(argv[1], "r");
	yydebug = 0;
	printf("START COMPILACION\n");
	symbolTable = NULL;
	do 
	{
		yyparse();
	} 
	while(!feof(yyin));
	imprimirTabla();
	guardarTabla();
	printf("\n --- INTERMEDIA --- \n");
	ast treeCopy = *tree;
	printAndSaveAST(tree);
	return 0;
}
void yyerror(const char* s) 
{
	fprintf(stderr, "Parse error: %s on line %d\n", s, yylineno);
	exit(1);
}

void guardarTipoDeclaracion(char* nombreIdentificador) 
{
  strcpy(tipoDeclaracionIDActual, nombreIdentificador);
}

void validarDeclaracionIDs(char* id) 
{
  int pos = nombre_existe_en_ts(id);
  if (pos == -1) 
  {
    fprintf(stderr, "\nVariable: %s no esta declarada en el bloque de declaracion, linea: %d\n", id, yylineno);
    exit(1);
  }
}

void compararIdentificadores(char* primerIdentificador, char* segundoIdentificador) 
{
  if (strcmp(primerIdentificador, segundoIdentificador) != 0) 
  {
    fprintf(stderr, "\n Los identificadores no son iguales, linea: %d\n", yylineno);
    exit(1);
  }
}

void validarDeclaracionID(char* id) 
{
  int i = 0;
  for(i = 0; i < indiceRecorrido; i++) 
  {
    if(strcmp(recorrido[i], id) == 0) 
    {
		fprintf(stderr, "\n El identificador ya se encuentra declarado, linea: %d\n", yylineno);
		exit(1);
    }
  }
  recorrido[recorridoIndex] = strdup(id);
  recorridoIndex++;
}

void validarTipo(ast* izquierda, ast* derecha, int fail) {
          
  if(derecha->valor != NULL) 
  {
    NodoSimbolo* simboloIzquierdo = nombre_existe_en_ts(izquierda->valor);
    NodoSimbolo* simboloDerecho = nombre_existe_en_ts(derecha->valor);
    if(symbolderecha != NULL && symbolizquierda != NULL) 
    {
      if(fail == 1 && (
          strcmp(simboloIzquierdo->tipo, "STRING") == 0 || 
          strcmp(simboloIzquierdo->tipo, "CTE_STRING") == 0 ||
          strcmp(simboloDerecho->tipo, "STRING") == 0 || 
          strcmp(simboloDerecho->tipo, "CTE_STRING") == 0)) 
      {
        fprintf(stderr, "\n Operacion incompatible, linea: %d\n", yylineno);
        exit(1);
      }
    }
  }

  
}

void validarAsignacion(char* id, ast* exp) 
{
   int pos = nombre_existe_en_ts(id);
   int posExp = nombre_existe_en_ts(exp->valor);
   struct registro_ts simbolo = tabla_simbolos[pos];
   struct registro_ts exP = tabla_simbolos[posExp];
   if (symbol != NULL && valorArbol != NULL) 
   {
	if((strcmp(simbolo.tipo, "INT") == 0 || strcmp(simbolo.tipo, "FLOAT") == 0) && (strcmp(exP.tipo, "STRING") == 0 || strcmp(exP.tipo, "CTE_STRING") == 0 )) 
	{
		fprintf(stderr, "\n Asignacion incompatible, linea: %d\n", yylineno);
		exit(1);
	}
	if((strcmp(simbolo.tipo, "STRING") == 0) && (strcmp(exP.tipo, "INT") == 0 || strcmp(exP.tipo, "FLOAT") == 0  || strcmp(exP->tipo, "CTE_INT") == 0 || strcmp(exP->tipo, "CTE_REAL") == 0 )) 
	{
		fprintf(stderr, "\n Asignacion incompatible, linea: %d\n", yylineno);
		exit(1);
	}
   }
}