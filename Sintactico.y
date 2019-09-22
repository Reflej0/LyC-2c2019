%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol.h"
#include "tree.h"
#include <string.h>

#define YYDEBUG 1
extern int yylex();
extern int yyparse();
extern yylineno;
extern FILE* yyin;

int tipos_variables = 0;
int variables = 0;
symbolNode* comprobarTipoEnteroFilter;
symbolNode* auxx;
char tiposVariablesAux[20][20];
int recorrerTiposVariablesAux = 0;
void validateIdIsDeclared();
void validateType();
void validateAsignation();

char* seen[200];
int seenIndex = 0;

ast* tree;

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

%type <ast> expresion
%type <ast> termino
%type <ast> factor
%type <ast> asignacion
%type <ast> comparacion
%type <ast> condicion
%type <ast> read
%type <ast> print
%type <ast> decision
%type <ast> filterlist
%type <ast> filter
%type <ast> comparacion_filter
%type <ast> condicion_filter
%type <ast> iteracion
%type <ast> asignacion_constante
%type <ast> bloque
%type <ast> lista_variables
%type <ast> tipo_variable
%type <ast> declaracion_variable
%type <ast> declaracion_variables
%type <ast> bloque_declaracion_variables
%type <ast> sentencia_declaracion
%type <ast> sentencia
%type <ast> programa

%union 
{
  int intVal;
  float floatVal;
  char strVal[30];
  struct treeNode* ast;
  char* auxLogicOperator;
}

%%


programa: sentencia_declaracion {printf("\n Regla: COMPILACION EXITOSA\n"); $$ = $1; tree = $$;}
  ;

sentencia_declaracion: bloque_declaracion_variables bloque {printf("\n Regla: sentencia: bloque_declaracion_variables bloque \n"); cleanWithoutType(); $$ = $2;}
  | bloque_declaracion_variables {printf("\n Regla: sentencia: bloque_declaracion_variables \n");}
  ;

bloque_declaracion_variables: VAR declaracion_variables ENDVAR {printf("\n Regla: bloque_declaracion_variables: VAR declaracion_variables ENDVAR \n");}
  ;

declaracion_variables: declaracion_variables declaracion_variable {printf("\n Regla: declaracion_variables: declaracion_variables declaracion_variable \n");}
  | declaracion_variable {printf("\n Regla: declaracion_variables: declaracion_variable \n");}

declaracion_variable: C_A lista_tipos_variable C_C DOS_PUNTOS C_A lista_variables C_C {printf("\n Regla: declaracion_variable: C_A lista_tipo_variable C_C DOS_PUNTOS C_A lista_variables C_C\n"); recorrerTiposVariablesAux=0; variables=0; tipos_variables=0;}
  ;

lista_tipos_variable: lista_tipos_variable COMA tipo_variable {printf("\n lista_tipos_variable: lista_tipos_variable COMA tipo_variable \n"); tipos_variables++;}
  | tipo_variable {printf("\n lista_tipos_variable: tipo_variable \n"); tipos_variables++;};

tipo_variable: INT {printf("\n Regla: tipo_variable: INT \n"); strcpy(tiposVariablesAux[recorrerTiposVariablesAux], "INT"); recorrerTiposVariablesAux++;}
  | FLOAT {printf("\n Regla: tipo_variable: FLOAT \n"); strcpy(tiposVariablesAux[recorrerTiposVariablesAux], "FLOAT"); recorrerTiposVariablesAux++;}
  | STRING {printf("\n Regla: tipo_variable: STRING \n"); strcpy(tiposVariablesAux[recorrerTiposVariablesAux], "STRING"); recorrerTiposVariablesAux++;}
  ;
lista_variables: lista_variables COMA ID {printf("\n Regla: lista_variables: lista_variables COMA ID \n"); auxx = findSymbol($3); strcpy(auxx->type, tiposVariablesAux[variables]); variables++;} 
  | ID {printf("\n Regla: lista_variables: ID \n", $1, variables); auxx = findSymbol($1); strcpy(auxx->type, tiposVariablesAux[variables]); variables++;}
  ;

bloque: sentencia {$$ = $1; printf("\n Regla: bloque: sentencia \n");}
  | bloque sentencia {$$ = newNode("BLOQUE", $1, $2); printf("\n Regla: bloque: bloque sentencia \n");}
  ;

sentencia: decision {$$ = $1; printf("\n Regla: sentencia: decision \n");}
  | asignacion {$$ = $1; printf("\n Regla: sentencia: asignacion \n");}
  | print {$$ = $1; printf("\n Regla: sentencia: print \n");}
  | read {$$ = $1; printf("\n Regla: sentencia: read \n");}
  | iteracion {$$ = $1; printf("\n Regla: sentencia: iteracion \n");}
  | asignacion_constante  {$$ = $1; printf("Regla: asignacion_constante OK\n");}
  ;

decision: IF P_A condicion P_C bloque ELSE bloque ENDIF {printf("\n Regla: decision: IF P_A condicion P_C bloque ELSE bloque ENDIF \n");}
  | IF P_A condicion P_C bloque ENDIF {$$ = newNode("IF", $3, $5); printf("\n Regla: decision: IF P_A condicion P_C bloque ENDIF \n");}
  ;

asignacion: ID ASIG expresion {validateAsignation($1, $3);validateIdIsDeclared($1); $$ = newNode("=", newLeaf($1), $3); printf("\n Regla: asignacion: ID ASIG expresion \n");};

asignacion_constante: CONST ID ASIG expresion {printf("\n Regla: asignacion_constante: CONST ID ASIG expresion \n");};

iteracion: REPEAT bloque UNTIL P_A condicion P_C {$$ = newNode("REPEAT", $5, $2); printf("\n Regla: iteracion: REPEAT bloque UNTIL P_A condicion P_C \n");};

condicion_filter: comparacion_filter { printf("\n Regla: condicion_filter: comparacion_filter \n");}
  | comparacion_filter logic_concatenator comparacion_filter {printf("\n Regla: condicion_filter: comparacion_filter logic_concatenator comparacion_filter \n");}
  | NOT P_A comparacion_filter P_C {printf("\n Regla: condicion_filter: NOT comparacion_filter \n");}
  ;

comparacion_filter: GUION_BAJO logic_operator  expresion {printf("\n Regla: comparacion_filter: expresion  logic_operator  expresion \n");}
  ;

filter: FILTER P_A condicion_filter COMA C_A filterlist C_C P_C {printf("\n Regla: filter: FILTER P_A condicion_filter COMA C_A filterlist C_C P_C \n");}
  ;

filterlist: filterlist COMA ID {printf("\n Regla: filterlist: filterlist COMA ID \n");}
      | ID {printf("\n Regla: filterlist: ID \n"); comprobarTipoEnteroFilter = findSymbol($1); if(strcmp(comprobarTipoEnteroFilter->type, "INT")!=0){printf("El metodo Filter solo acepta variables del tipo INT"); exit(1);}}
      ;

print: PRINT ID {validateIdIsDeclared($2); $$ = newNode("PRINT", newLeaf($2), NULL); printf("\n Regla: print: PRINT ID \n");}
  | PRINT CTE_INT {$$ = newNode("PRINT",newLeaf(getSymbolName(&($2),1)), NULL); printf("\n Regla: print: PRINT CTE_INT \n");}
  | PRINT CTE_REAL {$$ = newNode("PRINT",newLeaf(getSymbolName(&($2),2)), NULL); printf("\n Regla: print: PRINT CTE_REAL \n");}
  | PRINT CTE_STRING {$$ = newNode("PRINT",newLeaf(getSymbolName(&($2),3)), NULL); printf("\n Regla: print: PRINT CTE_STRING \n");}
  ;

read: READ ID {$$ = newNode("READ", newLeaf($2), NULL); printf("\n Regla: read: READ ID \n");};

condicion: comparacion {$$ = $1; printf("\n Regla: condicion: comparacion \n");}
  | comparacion logic_concatenator comparacion {$$ = newNode($2, $1, $3); printf("\n Regla: condicion: comparacion logic_concatenator comparacion \n");}
  | NOT P_A comparacion P_C {$$ = newNode("!", $3, NULL); printf("\n Regla: condicion: NOT comparacion \n");}
  ;

comparacion: expresion  logic_operator  expresion {validateType($1, $3, 1); $$ = newNode($2, $1, $3); printf("\n Regla: comparacion: expresion  logic_operator  expresion \n");}
  ;

logic_operator: IGUAL {$$ = "="; printf("\n Regla: logic_operator: IGUAL \n");}
  | DISTINTO {$$ = "!=";printf("\n Regla: logic_operator: DISTINTO \n");}
  | MAYOR {$$ = ">";printf("\n Regla: logic_operator: MAYOR \n");}
  | MAYOR_IGUAL {$$ = ">=";printf("\n Regla: logic_operator: MAYOR_IGUAL \n");}
  | MENOR {$$ = "<";printf("\n Regla: logic_operator: MENOR \n");}
  | MENOR_IGUAL {$$ = "<=";printf("\n Regla: logic_operator: MENOR_IGUAL \n");}
  ;

logic_concatenator: OR {$$ = "OR"; printf("\n Regla: logic_concatenator: OR \n");}
  | AND {$$ = "AND"; printf("\n Regla: logic_concatenator: AND \n");}
  ;

expresion: expresion OP_SUMA termino {validateType($1, $3, 1); $$ = newNode("+", $1, $3); printf("\n Regla: expresion: expresion OP_SUMA termino\n");}
  | expresion OP_RESTA termino {validateType($1, $3, 1); $$ = newNode("-", $1, $3); printf("\n Regla: expresion: expresion OP_RESTA termino\n");}
  | termino {$$ = $1; printf("\n Regla: expresion: termino\n");}
  ;

termino: termino OP_MULT factor {validateType($1, $3, 1); $$ = newNode("*", $1, $3); printf("\n Regla: termino: termino OP_MULT factor\n");}
  | termino OP_DIV factor {validateType($1, $3, 1); $$ = newNode("/", $1, $3); printf("\n Regla: termino: termino OP_DIV factor\n");}
  | factor {$$ = $1; printf("\n Regla: termino: factor\n");}
  ;

factor: ID {$$ = newLeaf($1); printf("\n Regla: factor: ID \n");}
  | CTE_INT {$$ = newLeaf(getSymbolName(&($1),1)); printf("\n Regla: factor: CTE_INT \n");}
  | CTE_REAL {$$ = newLeaf(getSymbolName(&($1),2)); printf("\n Regla: factor: CTE_REAL \n");}
  | CTE_STRING {$$ = newLeaf(getSymbolName($1,3)); printf("\n Regla: factor: CTE_STRING \n");}
  | P_A expresion P_C {$$ = $2; printf("\n Regla: factor: P_A expresion P_C \n");}
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
  printf("\n --- INTERMEDIA --- \n");
  ast treeCopy = *tree;
  printAndSaveAST(tree);
	return 0;
}

void validateAsignation(char* id, ast* exp) {
   symbolNode* symbol = findSymbol(id);
   symbolNode* treeValue = findSymbol(exp->value);
   if (symbol != NULL && treeValue != NULL) {
     if((strcmp(symbol->type, "INT") == 0 || strcmp(symbol->type, "FLOAT") == 0) && (strcmp(treeValue->type, "STRING") == 0 || strcmp(treeValue->type, "STRING_C") == 0 )) {
       fprintf(stderr, "\n Incompatible assignment, line: %d\n", yylineno);
       exit(1);
     }


     if((strcmp(symbol->type, "STRING") == 0) && (strcmp(treeValue->type, "INT") == 0 || strcmp(treeValue->type, "FLOAT") == 0  || strcmp(treeValue->type, "INTEGER_C") == 0 || strcmp(treeValue->type, "FLOAT_C") == 0 )) {
       fprintf(stderr, "\n Incompatible assignment, line: %d\n", yylineno);
       exit(1);
     }
   }
}

void validateIdIsDeclared(char* id) {
  symbolNode* symbol = findSymbol(id);
  if (symbol == NULL || strcmp(symbol->type, "") == 0) {
    fprintf(stderr, "\nVariable: %s is not declared on the declaration block on line %d\n", id, yylineno);
    exit(1);
  }
}

void validateType(ast* left, ast* right, int fail) {
          
  if(right->value != NULL) {
    symbolNode* symbolLeft = findSymbol(left->value);
    symbolNode* symbolRight = findSymbol(right->value);
    if(symbolRight != NULL && symbolLeft != NULL) {
      if(fail == 1 && (
          strcmp(symbolLeft->type, "STRING") == 0 || 
          strcmp(symbolLeft->type, "STRING_C") == 0 ||
          strcmp(symbolRight->type, "STRING") == 0 || 
          strcmp(symbolRight->type, "STRING_C") == 0)) {
        fprintf(stderr, "\n Incompatible operation, line: %d\n", yylineno);
        exit(1); //HAY UN ERROR VER DESPUES CON NUESTRO LOTE DE PRUEBAS.
      }
    }
  }

  
}


