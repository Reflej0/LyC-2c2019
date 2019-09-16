
%{
  #include <float.h>
  #include "y.tab.h"
  #include <string.h>

  void validarLimitesConstanteString();
  void validarLimitesConstanteReal();
  void validarLimitesConstanteInt();
  void validarID();
  char* substringIfNeeded();

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

{CONST}			{ return CONST; }
{FILTER}		{ return FILTER; }

">"             { return MAYOR; }
">="            { return MAYOR_IGUAL; }
"<"             { return MENOR; }
"<="            { return MENOR_IGUAL; }
"=="            { return IGUAL; }
"!="            { return DISTINTO; }

{FLOAT} {strcpy(yylval.strVal, yytext);return FLOAT;}
{INT} {strcpy(yylval.strVal, yytext); return INT;}
{STRING} {strcpy(yylval.strVal, yytext); return STRING;}
{CTE_INT} {validarLimitesConstanteInt(); yylval.intVal = atoi(substringIfNeeded()); insert(yytext); return CTE_INT;}
{CTE_STRING} {validarLimitesConstanteString(); strcpy(yylval.strVal, yytext); insert(yytext); return CTE_STRING;}
{CTE_REAL} {validarLimitesConstanteReal(); yylval.floatVal = atof(yytext); insert(yytext); return CTE_REAL;}
{ID} {strcpy(yylval.strVal, yytext); validarID(); insert(yytext); return ID;}
" "
"\t"
"\n"		    
{COMENTARIO}
<<EOF>> {yyterminate();}

%%


void validarLimitesConstanteString() 
{
  if (yyleng > 30) 
  {
    printf("Longitud maxima excedida en linea %d\n", yylineno);
    exit(1);
  }
}

void validarLimitesConstanteReal() 
{
  if (atof(yytext) > FLT_MAX || yyleng > 39) 
  {
    printf("Valor maximo excedido en linea %d\n", yylineno);
    exit(1);
  }
}


void validarLimitesConstanteInt() 
{
  if (atoi(yytext) > 32767) 
  {
    printf("Valor maximo excedido en linea %d\n", yylineno);
    exit(1);
  }
}

void validarID()
{
  if (yyleng > 10) 
  {
    printf("Longitud maxima excedida en linea %d\n", yylineno);
    fprintf(stderr, "Fin de ejecucion.\n");
    system ("Pause");
    exit (1);
  }
}

char* substringIfNeeded() 
{
  char* yyTextCopy = strdup(yytext);
 
  if(yyTextCopy[0] == '0') 
  {
    if(yyTextCopy[1] == 'b') 
    {
      yyTextCopy= (char*) substring(yyTextCopy, 3, strlen(yyTextCopy));
      int transformedValue = (int) strtol(yyTextCopy, NULL, 2);
      itoa(transformedValue, yyTextCopy, 10);
    } 
    else if(yyTextCopy[1] == 'x') 
    {
      yyTextCopy = (char*) substring(yyTextCopy, 3, strlen(yyTextCopy));
      int transformedValue = (int) strtol(yyTextCopy, NULL, 16);
      itoa(transformedValue, yyTextCopy, 10);
    }  
  }
  return yyTextCopy;
}

void yyerror (char const *s) 
{
   fprintf (stderr, "%s\n", s);
 }
