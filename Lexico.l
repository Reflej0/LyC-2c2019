
%{
  #include <float.h>
  #include "y.tab.h"
  #include <string.h>

  void checkStringConstantLimits();
  void checkFloatConstantLimits();
  void checkIntegerConstantLimits();
  char* substringIfNeeded();
%}
%option noyywrap
%option yylineno

while "WHILE"
if "IF"
for "FOR"
defvar "DEFVAR"
enddef "ENDDEF"
float "FLOAT"
int "INT"
string "STRING"
next "NEXT"
to "TO"
display "DISPLAY"
get "GET"
and "AND"
or "OR"
do "DO"
in "IN"
endwhile "ENDWHILE"
comma ","
comment "*/"(.*|\n|\r)"/*"
float_constant ([0-9]+"."[0-9]+)|([0-9]*"."[0-9]+)|([0-9]+"."[0-9]*)
string_constant  \".*\"
integer_constant ([0-9]+)|("0b"(1|0)+)|("0x"([0-9]|[ABCDEF])+)
id [a-zA-Z]([a-zA-Z]|[0-9])*
space " "
opening_parenthesis "("
closing_parenthesis ")"
sum_operator "+"
minus_operator "-"
divide_operator "/"
multiplier_operator "*"
assignment_operator ":="
equals_logic_operator "=="
not_equals_logic_operator "!="
not_logic_operator "!"
greater_logic_operator ">"
greater_or_equal_logic_operator ">="
lower_logic_operator "<"
lower_or_equal_logic_operator "<="
opening_key "{"
closing_key "}"
opening_square_bracket "["
closing_square_bracket "]"
semicolon ";"
colon ":"


%%

{while} {return WHILE;}
{if} {return IF;}
{for} {return FOR;}
{defvar} {return DEFVAR;}
{enddef} {return ENDDEF;}
{float} {strcpy(yylval.string_value, yytext); return FLOAT_TYPE;}
{int} strcpy(yylval.string_value, yytext); {return INT_TYPE;}
{string} {strcpy(yylval.string_value, yytext); return STRING_TYPE;}
{next} {return NEXT;}
{to} {return TO;}
{display} {return DISPLAY;}
{get} {return GET;}
{and} {return AND;}
{or} {return OR;}
{in} {return IN;}
{do} {return DO;}
{endwhile} {return ENDWHILE;}
{comma} {return COMMA;}
{closing_parenthesis} {return CLOSING_PARENTHESIS;}
{opening_parenthesis} {return OPENING_PARENTHESIS;}
{closing_key} {return CLOSING_KEY;}
{opening_key} {return OPENING_KEY;}
{opening_square_bracket} {return OPENING_SQUARE_BRACKET;}
{closing_square_bracket} {return CLOSING_SQUARE_BRACKET;}
{integer_constant} {checkIntegerConstantLimits(); yylval.integer_value = atoi(substringIfNeeded()); insert(yytext); return INTEGER_CONSTANT;}
{string_constant} {checkStringConstantLimits(); strcpy(yylval.string_value, yytext); insert(yytext); return STRING_CONSTANT;}
{float_constant} {checkFloatConstantLimits(); yylval.float_value = atof(yytext); insert(yytext); return FLOAT_CONSTANT;}
{id} {strcpy(yylval.string_value, yytext); insert(yytext); return ID;}
{assignment_operator} {return ASSIGNMENT_OPERATOR;}
{sum_operator} {return SUM_OPERATOR;}
{minus_operator} {return MINUS_OPERATOR;}
{multiplier_operator} {return MULTIPLIER_OPERATOR;}
{divide_operator} {return DIVIDE_OPERATOR;}
{equals_logic_operator} {return EQUALS_LOGIC_OPERATOR;}
{not_equals_logic_operator} {return NOT_EQUALS_LOGIC_OPERATOR;}
{not_logic_operator} {return NOT_LOGIC_OPERATOR;}
{greater_logic_operator} {return GREATER_LOGIC_OPERATOR;}
{greater_or_equal_logic_operator} {return GREATER_OR_EQUAL_LOGIC_OPERATOR;}
{lower_logic_operator} {return LOWER_LOGIC_OPERATOR;}
{lower_or_equal_logic_operator} {return LOWER_OR_EQUAL_LOGIC_OPERATOR;}
{semicolon} {return SEMICOLON;}
{colon} {return COLON;}
{space}
"\n"
"\r\n"
"\t"
{comment}
. {printf("Unrecognized token %s\n", yytext); exit(1);}
<<EOF>> {yyterminate();}

%%


void checkStringConstantLimits() {
  if (yyleng > 30) {
    printf("Max length exceeded on line %d\n", yylineno);
    exit(1);
  }
}

void checkFloatConstantLimits() {
  if (atof(yytext) > FLT_MAX || yyleng > 39) {
    printf("Max value exceeded on line %d\n", yylineno);
    exit(1);
  }
}


void checkIntegerConstantLimits() {
  if (atoi(yytext) > 32767) {
    printf("Max value exceeded on line %d\n", yylineno);
    exit(1);
  }
}


char* substringIfNeeded() {
  char* yyTextCopy = strdup(yytext);
 
  if(yyTextCopy[0] == '0') {
    if(yyTextCopy[1] == 'b') {
      yyTextCopy= (char*) substring(yyTextCopy, 3, strlen(yyTextCopy));
      int transformedValue = (int) strtol(yyTextCopy, NULL, 2);
      itoa(transformedValue, yyTextCopy, 10);
    } else if(yyTextCopy[1] == 'x') {
      yyTextCopy = (char*) substring(yyTextCopy, 3, strlen(yyTextCopy));
      int transformedValue = (int) strtol(yyTextCopy, NULL, 16);
      itoa(transformedValue, yyTextCopy, 10);
      
    }
      
  }
  return yyTextCopy;
}
