%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <float.h>
#include <limits.h>
#include "y.tab.h"
#define _INT_MIN 0
#define _INT_MAX 32767

FILE *yyin;

/* Tabla de simbolos */

struct registro_ts 
{
	char *nombre;
	char *tipo;
	char *valor;
	char *longitud;
};

struct registro_ts tabla_simbolos[200];
int cant_reg = 0;

/* FUNCIONES */
int validarInt(int entero);
int insertar_cteint_en_ts(int entero);

int validarString(char *str);
int insertar_ctestring_en_ts(char *str);

int validarReal(float flotante);
int insertar_ctereal_en_ts(float flotante);

int validarID(char *str);
int insertar_id_en_ts(char *id);


void mensaje_error();
int nombre_existe_en_ts(char *id);
void existe_en_ts(char *id);
void insertar_tabla_simbolos(char *nombre, char *tipo, char *valor, char *longitud);
void save_reg_ts();
void mostrar_ts();
void guardarTipos(int variableActual, char listaVariables[][20], char tipoActual[]);
char* getNombreSimbolo(void *punteroSimbolo, int tipo);

%}

%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
DELIM           [ \t\n\r]
CARACTER        [a-z|A-Z|0-9|=|>|<|!|:|+|-|*|/|?|¿|!|¡|@|%|#|&|°|´|^|`|~|/|\\|-|_|.|,|;|¬||]
VALID_STRING    ({CARACTER}+|{DELIM})*
COMENTARIO      --\/.({CARACTER}|{DELIM})*.\/--
                
CTE_STRING      \"{VALID_STRING}\"
CTE_REAL        -?{DIGITO}+"."{DIGITO}*
CTE_INT         -?{DIGITO}+
ID				{LETRA}({LETRA}|{DIGITO}|_)*

REPEAT          [Rr][Ee][Pp][Ee][Aa][Tt]
UNTIL          	[Uu][Nn][Tt][Ii][Ll]
IF				[Ii][Ff]
ELSE			[Ee][Ll][Ss][Ee]
ENDIF			[Ee][Nn][Dd][Ii][Ff]
AND				[Aa][Nn][Dd]
OR				[Oo][Rr]
NOT				[Nn][Oo][Tt]
INT				[Ii][Nn][Tt]
FLOAT			[Ff][Ll][Oo][Aa][Tt]
STRING			[Ss][Tt][Rr][Ii][Nn][Gg]
VAR				[Vv][Aa][Rr]
ENDVAR			[Ee][Nn][Dd][Vv][Aa][Rr]
PRINT			[Pp][Rr][Ii][Nn][Tt]
READ			[Rr][Ee][Aa][Dd]
CONST			[Cc][Oo][Nn][Ss][Tt]
FILTER			[Ff][Ii][Ll][Tt][Ee][Rr]

%%
"+"				{ return OP_SUMA; }
"-"				{ return OP_RESTA; }
"*"				{ return OP_MULT; }
"/"				{ return OP_DIV; }
"="			    { return ASIG; }
"("				{ return P_A; }
")"				{ return P_C; }
"["             { return C_A; }
"]"             { return C_C; }
";"             { return PUNTO_COMA; }
","             { return COMA; }
":"				{ return DOS_PUNTOS; }
"_"				{ return GUION_BAJO; }
{REPEAT}        { return REPEAT; } 
{UNTIL}        	{ return UNTIL; } 
{IF}			{ return IF; }
{ELSE}			{ return ELSE; }
{ENDIF}			{ return ENDIF; }
{AND}			{ return AND; }
{OR}			{ return OR; }
{NOT}           { return NOT; }

{VAR}			{ return VAR; }
{ENDVAR}		{ return ENDVAR; }

{READ}          { return READ; }
{PRINT}       	{ return PRINT; }

{INT}			{ return INT; }
{FLOAT}			{ return FLOAT; }
{STRING}		{ return STRING; }

{CONST}			{ return CONST; }
{FILTER}		{ return FILTER; }

">"             { return MAYOR; }
">="            { return MAYOR_IGUAL; }
"<"             { return MENOR; }
"<="            { return MENOR_IGUAL; }
"=="            { return IGUAL; }
"!="            { return DISTINTO; }

{ID}			{ yylval.strVal = strdup(yytext); validarID(yylval.strVal); return ID; }
{CTE_STRING}	{ yylval.strVal = strdup(yytext); 

				validarString(yylval.strVal); 
				
				/** Esto lo hice porque me agarraba las comillas, creo que esta mal la regex...
					arreglar en versiones futuras, por ahora esto funciona **/
					
					yylval.strVal = malloc(yyleng - 1);  
					memcpy (yylval.strVal, yytext + 1, yyleng - 2); 
					yylval.strVal[yyleng - 2] = 0; 
				/** fin del codigo rancio**/
				
				insertar_ctestring_en_ts(yylval.strVal); 
				
				return CTE_STRING; }
{CTE_INT}		{ yylval.intVal = atoi(yytext); validarInt(yylval.intVal); insertar_cteint_en_ts(yylval.intVal); return CTE_INT; }
{CTE_REAL}		{ yylval.realVal = atof(yytext); validarReal(yylval.realVal); insertar_ctereal_en_ts(yylval.realVal); return CTE_REAL; }

" "
"\t"
"\n"		    
{COMENTARIO}   
%%


/* 
	Funcion para validar el rango de enteros 
*/
int validarInt(int entero)
{

	if(entero < _INT_MIN || entero > _INT_MAX){
		printf("(!) ERROR: Constante entera fuera de rango (32 bits maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}
	return 1;
}

int insertar_cteint_en_ts(int entero)
{
	char *valor = (char*) malloc(sizeof(int));
	itoa(entero, valor, 10);

	char *nombre = (char*) malloc(sizeof(int)+1);
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, valor);
	
	if (nombre_existe_en_ts(nombre) == -1)
		insertar_tabla_simbolos(nombre, "CTE_INT", valor, "-");
	return 1;
}

/*
	Funcion para validar string 
*/
int validarString(char *str)
{
	if(strlen(str) > 30){
		printf("(!) ERROR: Constante string fuera de rango (30 caracteres maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}else{
		//printf(" Valide bien la cadena! : %s\n", str);
	}
	
	return 1;
}

int insertar_ctestring_en_ts(char *str) 
{
	char *nombre = (char*) malloc(31*sizeof(char));
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, str);
	
	char *longitud = (char*) malloc(10*sizeof(char));	
	itoa(strlen(str), longitud, 10);

	if (nombre_existe_en_ts(nombre) == -1)
		insertar_tabla_simbolos(nombre, "CTE_STRING", str, longitud);
	return 1;
}

/*
	Funcion para validar float 
*/
int validarReal(float real)
{

	if(real < FLT_MIN || real > FLT_MAX){
		printf("(!) ERROR: Constante real fuera de rango (-1.17549e-38; 3.40282e38) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}else{
		//printf("Valide bien float ! \n");
	}
	return 1;
}

int insertar_ctereal_en_ts(float flotante)
{
	char *valor = (char*) malloc(sizeof(float));
	snprintf(valor, sizeof(float), "%f", flotante);

	char *nombre = (char*) malloc(sizeof(float)+1);
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, valor);
	
	if (nombre_existe_en_ts(nombre) == -1)
		insertar_tabla_simbolos(nombre, "CTE_REAL", valor, "-");
	return 1;
}

/*
	Funcion para validar identificador
*/
int validarID(char *str)
{
    int largo = strlen(str);
 
	if(largo > 10){
		printf("(!) ERROR: Identificador fuera de rango (10 caracteres maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}else{
		//printf(" Valide bien el identificador! : %s\n", str);
	}
	
	return 1;
}

int insertar_id_en_ts(char *id)
{
	if (nombre_existe_en_ts(id) == -1) 
		insertar_tabla_simbolos(id, "","","-");
	return 1;
}

int nombre_existe_en_ts(char *id) 
{
	int i;
	for(i=0;i<cant_reg;i++){
		if (strcmpi(id, tabla_simbolos[i].nombre) == 0 || strcmpi(id, tabla_simbolos[i].valor) == 0)
			return i;
	}
	return -1;
}

/* 
	Funcion para comprobar que un simbolo existe en la tabla de simbolos
*/

void existe_en_ts (char *id){
  if(nombre_existe_en_ts(id)==-1){
	printf("\nERROR: ID no declarado\n");
    yyerror();
  }
}

void existe_cte_en_ts (char *id){
  if(nombre_existe_en_ts(id)!=-1){
	printf("\nERROR: Las constantes con nombres no pueden ser redefinidas\n");
    yyerror();
  }
}


void insertar_tabla_simbolos(char *nombre, char *tipo, char *valor, char *longitud)
{
	struct registro_ts reg;
	
	reg.nombre = nombre;
	reg.tipo = tipo;
	reg.valor = valor;
	reg.longitud = longitud;
	
	tabla_simbolos[cant_reg] = reg;
	cant_reg++;
}

void guardarTabla()
{
	FILE *file = fopen("ts.txt", "a");
	
	if(file == NULL) 
	{
    	printf("(!) ERROR: No se pudo abrir el txt correspondiente a la tabla de simbolos\n");
	}
	else 
	{
		int i = 0;
		for (i; i < cant_reg; i++) 
		{
			//printf("%s\t%s\t%s\t%s\n", tabla_simbolos[i].nombre, tabla_simbolos[i].tipo, tabla_simbolos[i].valor, tabla_simbolos[i].longitud);
			fprintf(file, "%s\t%s\t%s\t%s\n", tabla_simbolos[i].nombre, tabla_simbolos[i].tipo, tabla_simbolos[i].valor, tabla_simbolos[i].longitud);
		}		
		fclose(file);
	}
}

void imprimirTabla()
{
	printf("\n\nMOSTRAR COMO QUEDO LA TS \n");
	int i = 0;
	for (i; i < cant_reg; i++) 
	{
		printf("%s\t%s\t%s\t%s\n", tabla_simbolos[i].nombre, tabla_simbolos[i].tipo, tabla_simbolos[i].valor, tabla_simbolos[i].longitud);	
	}
	printf("\n");
}

/* 
	Funcion para actualizar el tipo de una variable en la tabla de simbolos
*/

void guardarTipos(int variableActual, char listaVariables[][20], char tipoActual[]){
  int i;
  for(i=0; i<variableActual; i++){
    int pos=nombre_existe_en_ts(listaVariables[i]);
    if(pos!=-1) {
	  char *tipoDato = (char*) malloc(10*sizeof(char));
	  *tipoDato = '\0';
	  strcat(tipoDato, tipoActual);
	  tabla_simbolos[pos].tipo = tipoDato;
	}
  }
}

char* getNombreSimbolo(void *punteroSimbolo, int tipo) 
{
    char simbolo[220];
    int valorEntero;
    float valorReal;
    switch (type) {
        case 1:
            valorEntero = *(int*)simboloPointer;
            itoa(valorEntero, simbolo, 10);
            break;
        case 2:
            valorReal = *(float*)simboloPointer;
            gcvt (valorReal, 7, simbolo);
            break; 
        case 3:
            strcpy(simbolo, (char*)simboloPointer);
            break;
    }
    int pos = nombre_existe_en_ts(simbolo);
    if (pos == -1) {
        fprintf(stderr, "\n ERROR: simbolo %s no encontrado", simbolo);
        exit(1);
    }
    return strdup(tabla_simbolos[pos]); 
}
