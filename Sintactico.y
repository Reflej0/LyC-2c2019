%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"

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
void validarDeclaracionId();
void validarTipo();
void validarAsignacion();
void asignacionConstante();
void negarOperador();
ast* construccionArbolFilter();

char* seen[200];
int seenIndex = 0;

ast* tree;

//Variables para el manejo del filter.
int indexFilter = 0;
char filterList[20][20];
ast* auxExpFilter = NULL;
char* auxLogicOperatorFilter = NULL;
ast* auxExpFilter2 = NULL;
char* auxLogicOperatorFilter2 = NULL;
char* auxLogicConcatenatorFilter = NULL;
int filterNegado = 0;
int filterCompuesto = 0;
int banderaFor = -1;
ast* hojaIzquierdaFilter = NULL;
ast* vecFilter[20];
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

sentencia_declaracion: bloque_declaracion_variables bloque {printf("\n Regla: sentencia: bloque_declaracion_variables bloque \n"); limpiarSinTipo(); $$ = $2;}
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

decision: IF P_A condicion P_C bloque ELSE bloque ENDIF {$$ = newNode("IF", $3, newNode("CUERPO_IF_ELSE", $5, $7)); printf("\n Regla: decision: IF P_A condicion P_C bloque ELSE bloque ENDIF \n");}
  | IF P_A condicion P_C bloque ENDIF {$$ = newNode("IF", $3, $5); printf("\n Regla: decision: IF P_A condicion P_C bloque ENDIF \n");}
  ;

asignacion: ID ASIG expresion {validarAsignacion($1, $3);validarDeclaracionId($1); $$ = newNode("=", newLeaf($1), $3); printf("\n Regla: asignacion: ID ASIG expresion \n");};

asignacion_constante: CONST ID ASIG expresion {asignacionConstante($2, $4); $$ = newNode("=", newLeaf($2), $4); printf("\n Regla: asignacion_constante: CONST ID ASIG expresion \n");};

iteracion: REPEAT bloque UNTIL P_A condicion P_C {$$ = newNode("REPEAT", $5, $2); printf("\n Regla: iteracion: REPEAT bloque UNTIL P_A condicion P_C \n");};

condicion_filter: comparacion_filter {$$ = newNode("EMPTY", NULL, NULL); printf("\n Regla: condicion_filter: comparacion_filter \n");}
  | comparacion_filter {auxExpFilter2 = auxExpFilter; auxLogicOperatorFilter2 = auxLogicOperatorFilter;} logic_concatenator comparacion_filter {filterCompuesto=1; $$ = newNode("EMPTY", NULL, NULL); printf("\n Regla: condicion_filter: comparacion_filter logic_concatenator comparacion_filter \n");}
  | NOT P_A comparacion_filter P_C {filterNegado = 1; $$ = newNode("EMPTY", NULL, NULL); printf("\n Regla: condicion_filter: NOT comparacion_filter \n");}
  ;

//Debido a esta implementacion de arbol con $$, no puedo pasar por una regla y dejar sin completar el $$.
//Se almacenan los elementos de la regla que se utilizaran posteriormente en reglas posteriores.
//Y se crea un nodo ficticio en el arbol llamado EMPTY que se descartara en la construccion del ASM.
comparacion_filter: GUION_BAJO logic_operator expresion {auxExpFilter = $3; auxLogicOperatorFilter = $2; $$ = newNode("EMPTY", NULL, NULL); printf("\n Regla: comparacion_filter: expresion  logic_operator  expresion \n");}
  ;

filter: FILTER P_A condicion_filter COMA C_A filterlist C_C P_C 
{
  //Se agrega la variable auxiliar _filter con su tipo _int a la tabla de simbolos.
  insert("_filter");
  auxx = findSymbol("_filter");
  strcpy(auxx->type, "INT");
  //Si el filter es un filter negado, entonces niego el operador de la comparacion.
  if(filterNegado == 1)
  {
    negarOperador();
  }
  //Si la comparacion del filter implica una sola condicion.
  if(filterCompuesto == 0)
  {
    int ix = 0;
    //Recorrido de las variables del filter, almacenadas en el vector filterList.
    for(ix=0; ix<indexFilter-1; ix++)
    {
      //La primera comparacion la guardo porque forma parte de la hoja izquierda del filter, las demas van a estar a la derecha.
      if(banderaFor == -1)
      {
        hojaIzquierdaFilter = newNode("IF", newNode(auxLogicOperatorFilter, newLeaf(filterList[indexFilter-1]), auxExpFilter), newNode("=", newLeaf("_filter"), newLeaf(filterList[indexFilter-1])));
        banderaFor++;
      }
      //Guardado de los subarboles del filter.
      vecFilter[banderaFor] = newNode("IF", newNode(auxLogicOperatorFilter, newLeaf(filterList[ix]), auxExpFilter), newNode("=", newLeaf("_filter"), newLeaf(filterList[ix])));
      banderaFor++;
    }
    //Una vez recorrido el filterList ya estan almacenados los subarboles del filter, resta la union.
  }
  //Si la comparacion del filter implica dos condiciones
  else
  {
    int ix = 0;
    //Recorrido de las variables del filter, almacenadas en el vector filterList.
    for(ix=0; ix<indexFilter-1; ix++)
    {
      //La primera comparacion la guardo porque forma parte de la hoja izquierda del filter, las demas van a estar a la derecha.
      if(banderaFor == -1)
      {
        hojaIzquierdaFilter = newNode("IF", newNode(auxLogicConcatenatorFilter, newNode(auxLogicOperatorFilter2, newLeaf(filterList[indexFilter-1]), auxExpFilter2), newNode(auxLogicOperatorFilter, newLeaf(filterList[indexFilter-1]), auxExpFilter)), newNode("=", newLeaf("_filter"), newLeaf(filterList[indexFilter-1])));
        banderaFor++;
      }
      vecFilter[banderaFor] = newNode("IF", newNode(auxLogicConcatenatorFilter, newNode(auxLogicOperatorFilter2, newLeaf(filterList[ix]), auxExpFilter2), newNode(auxLogicOperatorFilter, newLeaf(filterList[ix]), auxExpFilter)), newNode("=", newLeaf("_filter"), newLeaf(filterList[ix])));
      banderaFor++;
    }
  }
  $$ = newNode("FILTER", hojaIzquierdaFilter, construccionArbolFilter());
  printf("\n Regla: filter: FILTER P_A condicion_filter COMA C_A filterlist C_C P_C \n"); 
  //Estado inicial de todas las variables implicadas en el filter.
  //Filter negado si la condicion implica un NOT antepuesto.
  filterNegado = 0;
  //Filter compuesto si la comparacion del filter implica una sola condicion.
  filterCompuesto = 0;
  //Variable que permite la iteracion por el vector filterList.
  indexFilter = 0;
  banderaFor = -1;
};

filterlist: filterlist COMA ID {$$ = newNode("EMPTY", NULL, NULL); printf("\n Regla: filterlist: filterlist COMA ID \n"); 
      comprobarTipoEnteroFilter = findSymbol($3);
      if(strcmp(comprobarTipoEnteroFilter->type, "INT")!=0){printf("El metodo Filter solo acepta variables del tipo INT"); exit(1);}
      strcpy(filterList[indexFilter], $3); indexFilter++;}
      | ID {$$ = newNode("EMPTY", NULL, NULL); printf("\n Regla: filterlist: ID \n"); comprobarTipoEnteroFilter = findSymbol($1);
      if(strcmp(comprobarTipoEnteroFilter->type, "INT")!=0){printf("El metodo Filter solo acepta variables del tipo INT"); exit(1);}
      strcpy(filterList[indexFilter], $1); indexFilter++;}

print: PRINT ID {validarDeclaracionId($2); $$ = newNode("PRINT", newLeaf($2), NULL); printf("\n Regla: print: PRINT ID \n");}
  | PRINT CTE_INT {$$ = newNode("PRINT",newLeaf(getSymbolName(&($2),1)), NULL); printf("\n Regla: print: PRINT CTE_INT \n");}
  | PRINT CTE_REAL {$$ = newNode("PRINT",newLeaf(getSymbolName(&($2),2)), NULL); printf("\n Regla: print: PRINT CTE_REAL \n");}
  | PRINT CTE_STRING {$$ = newNode("PRINT",newLeaf(getSymbolName(&($2),3)), NULL); printf("\n Regla: print: PRINT CTE_STRING \n");}
  ;

read: READ ID {$$ = newNode("READ", newLeaf($2), NULL); printf("\n Regla: read: READ ID \n");};

condicion: comparacion {$$ = $1; printf("\n Regla: condicion: comparacion \n");}
  | comparacion logic_concatenator comparacion {$$ = newNode($2, $1, $3); printf("\n Regla: condicion: comparacion logic_concatenator comparacion \n");}
  | NOT P_A comparacion P_C {$$ = newNode("!", $3, NULL); printf("\n Regla: condicion: NOT comparacion \n");}
  ;

comparacion: expresion  logic_operator  expresion {validarTipo($1, $3, 1); $$ = newNode($2, $1, $3); printf("\n Regla: comparacion: expresion  logic_operator  expresion \n");}
  ;

logic_operator: IGUAL {$$ = "="; printf("\n Regla: logic_operator: IGUAL \n");}
  | DISTINTO {$$ = "!=";printf("\n Regla: logic_operator: DISTINTO \n");}
  | MAYOR {$$ = ">";printf("\n Regla: logic_operator: MAYOR \n");}
  | MAYOR_IGUAL {$$ = ">=";printf("\n Regla: logic_operator: MAYOR_IGUAL \n");}
  | MENOR {$$ = "<";printf("\n Regla: logic_operator: MENOR \n");}
  | MENOR_IGUAL {$$ = "<=";printf("\n Regla: logic_operator: MENOR_IGUAL \n");}
  ;

logic_concatenator: OR {$$ = "OR"; printf("\n Regla: logic_concatenator: OR \n"); auxLogicConcatenatorFilter = "OR";}
  | AND {$$ = "AND"; printf("\n Regla: logic_concatenator: AND \n"); auxLogicConcatenatorFilter = "AND";}
  ;

expresion: expresion OP_SUMA termino {validarTipo($1, $3, 1); $$ = newNode("+", $1, $3); printf("\n Regla: expresion: expresion OP_SUMA termino\n");}
  | expresion OP_RESTA termino {validarTipo($1, $3, 1); $$ = newNode("-", $1, $3); printf("\n Regla: expresion: expresion OP_RESTA termino\n");}
  | termino {$$ = $1; printf("\n Regla: expresion: termino\n");}
  ;

termino: termino OP_MULT factor {validarTipo($1, $3, 1); $$ = newNode("*", $1, $3); printf("\n Regla: termino: termino OP_MULT factor\n");}
  | termino OP_DIV factor {validarTipo($1, $3, 1); $$ = newNode("/", $1, $3); printf("\n Regla: termino: termino OP_DIV factor\n");}
  | factor {$$ = $1; printf("\n Regla: termino: factor\n");}
  ;

factor: ID {$$ = newLeaf($1); printf("\n Regla: factor: ID \n");}
  | CTE_INT {$$ = newLeaf(getSymbolName(&($1),1)); printf("\n Regla: factor: CTE_INT \n");}
  | CTE_REAL {$$ = newLeaf(getSymbolName(&($1),2)); printf("\n Regla: factor: CTE_REAL \n");}
  | CTE_STRING {$$ = newLeaf(getSymbolName($1,3)); printf("\n Regla: factor: CTE_STRING \n");}
  | P_A expresion P_C {$$ = $2; printf("\n Regla: factor: P_A expresion P_C \n");}
  | filter { $$ = $1; printf("filter OK\n"); }
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
  printf("\n\n\n--- ASM EN ARCHIVO final.asm --- \n\n\n");
  generateAssembler(treeCopy);
  return 0;
}

//Esta funcion es recursiva, el arbol del filter es del tipo:
/*
    FILTER
0           ;
        1       ;
              2    ;
                  3  ;
                    4  NULL
Es decir mientras tenga elemento proximo el hijo derecho sera un ;
*/
ast* construccionArbolFilter()
{
  if(banderaFor == -1 || banderaFor == 0)
    return NULL;
  banderaFor--;
  ast* node = (ast*)malloc(sizeof(struct ast*)); 
  node->value = ";";
  node->left = vecFilter[banderaFor];
  node->right = construccionArbolFilter();
  return node;
}

//Esta funcion se utiliza en la regla del filter negado, y niega el operador de comparacion.
void negarOperador()
{
  if(strcmp(auxLogicOperatorFilter, "=")==0)
    auxLogicOperatorFilter = "!=";
  else if(strcmp(auxLogicOperatorFilter, "!=")==0)
    auxLogicOperatorFilter = "=";
  else if(strcmp(auxLogicOperatorFilter, ">")==0)
    auxLogicOperatorFilter = "<";
  else if(strcmp(auxLogicOperatorFilter, "<")==0)
    auxLogicOperatorFilter = ">";
  else if(strcmp(auxLogicOperatorFilter, "<=")==0)
    auxLogicOperatorFilter = ">=";
  else if(strcmp(auxLogicOperatorFilter, ">=")==0)
    auxLogicOperatorFilter = "<=";
}

void asignacionConstante(char* id, ast* exp)
{
  symbolNode* treeValueConst = findSymbol(exp->value);
  symbolNode* treeValueId = findSymbol(id);
  strcpy(treeValueId->type, treeValueConst->type);
  strcpy(treeValueId->value, treeValueConst->value);
  treeValueId->length = strlen(treeValueConst->value);
}

void validarAsignacion(char* id, ast* exp) 
{
   symbolNode* symbol = findSymbol(id);
   symbolNode* treeValue = findSymbol(exp->value);

   if(strcmp(symbol->type, "STRING_C") == 0 || strcmp(symbol->type, "INTEGER_C") == 0 || strcmp(symbol->type, "FLOATT_C") == 0)
   {
    printf("No se puede volver asignar valor a una constante, linea: %d\n", yylineno);
    exit(1);
   }

   if (symbol != NULL && treeValue != NULL) 
   {
     if((strcmp(symbol->type, "INT") == 0 || strcmp(symbol->type, "FLOAT") == 0) && (strcmp(treeValue->type, "STRING") == 0 || strcmp(treeValue->type, "STRING_C") == 0 )) 
     {
       fprintf(stderr, "\n Asignacion incompatible, linea: %d\n", yylineno);
       exit(1);
     }


     if((strcmp(symbol->type, "STRING") == 0) && (strcmp(treeValue->type, "INT") == 0 || strcmp(treeValue->type, "FLOAT") == 0  || strcmp(treeValue->type, "INTEGER_C") == 0 || strcmp(treeValue->type, "FLOAT_C") == 0 )) 
     {
       fprintf(stderr, "\n Asignacion incompatible, linea: %d\n", yylineno);
       exit(1);
     }
   }
}

void validarDeclaracionId(char* id) 
{
  symbolNode* symbol = findSymbol(id);
  if (symbol == NULL || strcmp(symbol->type, "") == 0) 
  {
    fprintf(stderr, "\nVariable: %s no esta declarada en el bloque de declaracion, linea: %d\n", id, yylineno);
    exit(1);
  }
}

void validarTipo(ast* left, ast* right, int fail) 
{
          
  if(right->value != NULL) 
  {
    symbolNode* symbolLeft = findSymbol(left->value);
    symbolNode* symbolRight = findSymbol(right->value);
    if(symbolRight != NULL && symbolLeft != NULL) 
    {
      if(fail == 1 && (
          strcmp(symbolLeft->type, "STRING") == 0 || 
          strcmp(symbolLeft->type, "STRING_C") == 0 ||
          strcmp(symbolRight->type, "STRING") == 0 || 
          strcmp(symbolRight->type, "STRING_C") == 0)) 
      {
        fprintf(stderr, "\n Operacion incompatible, linea: %d\n", yylineno);
        exit(1);
      }
    }
  }
}