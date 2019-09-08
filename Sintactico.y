%{
#include <stdio.h>
#include <stdlib.h>
#include "assembler.h"
#include <string.h>

#define YYDEBUG 1
extern int yylex();
extern int yyparse();
extern yylineno;
extern FILE* yyin;
void yyerror(const char* s);
void saveIdentifierDeclarationType();
char currentIdentifierDeclarationType[7];
void validateIdIsDeclared();
void compareIdentificators();
void validateIdDeclaration();
void validateType();
void validateAsignation();

char* seen[200];
int seenIndex = 0;

ast* tree;
%}





%token WHILE
%token IF
%token FOR
%token DEFVAR
%token ENDDEF
%token INT_TYPE
%token FLOAT_TYPE
%token STRING_TYPE
%token NEXT
%token TO
%token DISPLAY
%token GET
%token COMMENT
%token FLOAT_CONSTANT
%token STRING_CONSTANT
%token INTEGER_CONSTANT
%token ID
%token OPENING_PARENTHESIS
%token CLOSING_PARENTHESIS
%token ASSIGNMENT_OPERATOR
%token OPENING_KEY
%token CLOSING_KEY
%token OPENING_SQUARE_BRACKET
%token CLOSING_SQUARE_BRACKET
%token SEMICOLON
%token COLON
%left SUM_OPERATOR
%left MINUS_OPERATOR
%left DIVIDE_OPERATOR
%left MULTIPLIER_OPERATOR
%left EQUALS_LOGIC_OPERATOR
%left NOT_EQUALS_LOGIC_OPERATOR
%left NOT_LOGIC_OPERATOR
%left GREATER_LOGIC_OPERATOR
%left GREATER_OR_EQUAL_LOGIC_OPERATOR
%left LOWER_LOGIC_OPERATOR
%left LOWER_OR_EQUAL_LOGIC_OPERATOR
%left OR
%left AND
%token ENDWHILE
%token DO
%token IN
%token COMMA
%start program


%type <integer_value> INTEGER_CONSTANT
%type <float_value> FLOAT_CONSTANT
%type <string_value> STRING_CONSTANT
%type <string_value> ID
%type <string_value> INT_TYPE
%type <string_value> STRING_TYPE
%type <string_value> FLOAT_TYPE
%type <ast> expression
%type <ast> term
%type <ast> factor
%type <ast> assignment
%type <ast> comparation
%type <ast> condition
%type <ast> get
%type <ast> display
%type <ast> for_loop
%type <ast> algorithms
%type <ast> algorithm
%type <ast> while_loop
%type <ast> decision
%type <ast> sentence
%type <ast> program
%type <ast> while_special
%type <ast> expression_list
%type <auxLogicOperator> logic_operator
%type <auxLogicOperator> logic_concatenator

%union {
  int integer_value;
  float float_value;
  char string_value[30];
  struct treeNode* ast;
  char* auxLogicOperator;
}

%%


program: sentence {printf("\n Regla 0: SUCCESSFUL COMPILATION\n"); $$ = $1; tree = $$;}
  ;

sentence: variable_declaration_block algorithms {printf("\n Regla 1: sentence: variable_declaration_block algorithms \n"); $$ = $2;}
  | variable_declaration_block {printf("\n Regla 2: sentence: variable_declaration_block \n");}
  ;

algorithms: algorithm {$$ = $1; printf("\n Regla 3: algorithms: algorithm \n");}
  | algorithms algorithm {$$ = newNode("CUERPO_ALGORITMH", $1, $2); printf("\n Regla 4: algorithms: algorithms algorithm \n");}
  ;

algorithm: decision {printf("\n Regla 5: algorithm: decision \n"); $$ = $1;}
  | assignment {printf("\n Regla 6: algorithm: assignment \n"); $$ = $1;}
  | while_loop {printf("\n Regla 7: algorithm: while_loop \n"); $$ = $1;}
  | for_loop {printf("\n Regla 8: algorithm: for_loop \n"); $$ = $1;}
  | display {printf("\n Regla 9: algorithm: display \n"); $$ = $1;}
  | get {printf("\n Regla 10: algorithm: get \n"); $$ = $1;}
  | while_special {printf("\n Regla 11: algorithm: while_special \n"); $$ = $1;}
  ;

decision: IF OPENING_PARENTHESIS condition CLOSING_PARENTHESIS OPENING_KEY algorithms CLOSING_KEY {$$ = newNode("IF", $3, $6); printf("\n Regla 12: decision: IF OPENING_PARENTHESIS condition CLOSING_PARENTHESIS OPENING_KEY algorithms CLOSING_KEY \n");};

assignment: ID ASSIGNMENT_OPERATOR expression {validateAsignation($1, $3);validateIdIsDeclared($1); $$ = newNode("=", newLeaf($1), $3); printf("\n Regla 13: assignment: ID ASSIGNMENT_OPERATOR expression \n");};

while_loop: WHILE OPENING_PARENTHESIS condition CLOSING_PARENTHESIS OPENING_KEY algorithms CLOSING_KEY {$$ = newNode("WHILE", $3, $6); printf("\n Regla 14: while_loop: WHILE OPENING_PARENTHESIS condition CLOSING_PARENTHESIS OPENING_KEY algorithms CLOSING_KEY \n");};

while_special: WHILE ID IN OPENING_SQUARE_BRACKET expression_list CLOSING_SQUARE_BRACKET DO algorithms ENDWHILE {validateIdIsDeclared($2); $$ = newNode("WHILE_SPECIAL", newNode("IN", newLeaf($2), $5), $8); printf("\n Regla 15: while_special: WHILE ID IN OPENING_SQUARE_BRACKET expression_list CLOSING_SQUARE_BRACKET DO algorithms ENDWHILE \n");}
  ;

expression_list: expression_list COMMA expression {$$ = newNode("LIST", $1, $3); printf("\n Regla 16: expression_list: expression_list COMMA expression \n");}
  | expression {$$ = $1; printf("\n Regla 17: expression_list: expression \n");}
  ;

for_loop: FOR ID ASSIGNMENT_OPERATOR expression TO expression INTEGER_CONSTANT algorithms NEXT ID {
    compareIdentificators($2, $10);
    $$ = newNode("FOR", newNode("FOR_CONDITION", newNode("=", newLeaf($2), $4), newNode("TO", newLeaf($2), $6)), newNode("CUERPO_FOR", $8, newNode("NEXT", newLeaf($2), newLeaf(getSymbolName(&($7),1)))));
    printf("\n Regla 18: for_loop: FOR ID ASSIGNMENT_OPERATOR expression TO expression INTEGER_CONSTANT algorithms NEXT ID \n");
    }
  | FOR ID ASSIGNMENT_OPERATOR expression TO expression algorithms NEXT ID {
    compareIdentificators($2, $9);
    $$ = newNode("FOR", newNode("FOR_CONDITION", newNode("=", newLeaf($2), $4), newNode("TO", newLeaf($2), $6)), newNode("CUERPO_FOR", $7, newNode("NEXT", newLeaf($2), newLeaf("_1"))));   
    printf("\n Regla 19: for_loop: FOR ID ASSIGNMENT_OPERATOR expression TO expression algorithms NEXT ID \n");
    }
  ;

display: DISPLAY ID {validateIdIsDeclared($2); $$ = newNode("DISPLAY", newLeaf($2), NULL); printf("\n Regla 20: display: DISPLAY ID \n");}
  | DISPLAY INTEGER_CONSTANT {$$ = newNode("DISPLAY",newLeaf(getSymbolName(&($2),1)), NULL); printf("\n Regla 21: display: DISPLAY INTEGER_CONSTANT \n");}
  | DISPLAY FLOAT_CONSTANT {$$ = newNode("DISPLAY",newLeaf(getSymbolName(&($2),2)), NULL); printf("\n Regla 22: display: DISPLAY FLOAT_CONSTANT \n");}
  | DISPLAY STRING_CONSTANT {$$ = newNode("DISPLAY",newLeaf(getSymbolName(&($2),3)), NULL); printf("\n Regla 23: display: DISPLAY STRING_CONSTANT \n");}
  ;

get: GET ID {$$ = newNode("GET", newLeaf($2), NULL); printf("\n Regla 24: get: GET ID \n");};

condition: comparation {$$ = $1; printf("\n Regla 25: condition: comparation \n");}
  | comparation logic_concatenator comparation {$$ = newNode($2, $1, $3); printf("\n Regla 26: condition: comparation logic_concatenator comparation \n");}
  | NOT_LOGIC_OPERATOR comparation {$$ = newNode("!", $2, NULL); printf("\n Regla 27: condition: NOT_LOGIC_OPERATOR comparation \n");}
  ;

comparation: expression  logic_operator  expression {validateType($1, $3, 1); $$ = newNode($2, $1, $3); printf("\n Regla 28: comparation: expression  logic_operator  expression \n");}
  ;

logic_operator: EQUALS_LOGIC_OPERATOR {$$ = "="; printf("\n Regla 29: logic_operator: EQUALS_LOGIC_OPERATOR \n");}
  | NOT_EQUALS_LOGIC_OPERATOR {$$ = "!="; printf("\n Regla 30: logic_operator: NOT_EQUALS_LOGIC_OPERATOR \n");}
  | GREATER_LOGIC_OPERATOR {$$ = ">"; printf("\n Regla 31: logic_operator: GREATER_LOGIC_OPERATOR \n");}
  | GREATER_OR_EQUAL_LOGIC_OPERATOR {$$ = ">="; printf("\n Regla 32: logic_operator: GREATER_OR_EQUAL_LOGIC_OPERATOR \n");}
  | LOWER_LOGIC_OPERATOR {$$ = "<"; printf("\n Regla 33: logic_operator: LOWER_LOGIC_OPERATOR \n");}
  | LOWER_OR_EQUAL_LOGIC_OPERATOR {$$ = "<="; printf("\n Regla 34: logic_operator: LOWER_OR_EQUAL_LOGIC_OPERATOR \n");}
  ;

logic_concatenator: OR {$$ = "OR"; printf("\n Regla 35: logic_concatenator: OR \n");}
  | AND {$$ = "AND"; printf("\n Regla 36: logic_concatenator: AND \n");}
  ;

expression: expression SUM_OPERATOR term {validateType($1, $3, 1); $$ = newNode("+", $1, $3); printf("\n Regla 37: expression: expression SUM_OPERATOR term\n");}
  | expression MINUS_OPERATOR term {validateType($1, $3, 1); $$ = newNode("-", $1, $3); printf("\n Regla 38: expression: expression MINUS_OPERATOR term\n");}
  | term {$$ = $1; printf("\n Regla 39: expression: term\n");}
  ;

term: term MULTIPLIER_OPERATOR factor {validateType($1, $3, 1); $$ = newNode("*", $1, $3); printf("\n Regla 40: term: term MULTIPLIER_OPERATOR factor\n");}
  | term DIVIDE_OPERATOR factor {validateType($1, $3, 1); $$ = newNode("/", $1, $3); printf("\n Regla 41: term: term DIVIDE_OPERATOR factor\n");}
  | factor {$$ = $1; printf("\n Regla 42: term: factor\n");}
  ;

factor: ID {$$ = newLeaf($1); printf("\n Regla 43: factor: ID \n");}
  | INTEGER_CONSTANT {$$ = newLeaf(getSymbolName(&($1),1)); printf("\n Regla 44: factor: INTEGER_CONSTANT \n");}
  | FLOAT_CONSTANT {$$ = newLeaf(getSymbolName(&($1),2)); printf("\n Regla 45: factor: FLOAT_CONSTANT \n");}
  | STRING_CONSTANT {$$ = newLeaf(getSymbolName($1,3)); printf("\n Regla 46: factor: STRING_CONSTANT \n");}
  | OPENING_PARENTHESIS expression CLOSING_PARENTHESIS {$$ = $2; printf("\n Regla 47: factor: OPENING_PARENTHESIS expression CLOSING_PARENTHESIS \n");}
  ;



variable_declaration_block: DEFVAR variable_declarations ENDDEF {printf("\n Regla 48: variable_declaration_block: DEFVAR variable_declarations ENDDEF \n");}
  ;

variable_declarations: variable_declarations variable_declaration {printf("\n Regla 49: variable_declarations: variable_declarations variable_declaration \n");}
  | variable_declaration {printf("\n Regla 50: variable_declarations: variable_declaration \n");}

variable_declaration: variable_type COLON variable_list {putTypeIdentifierOnSymbolTable(currentIdentifierDeclarationType); printf("\n Regla 51: variable_declaration: variable_type COLON variable_list\n");}
  ;
variable_type: INT_TYPE {saveIdentifierDeclarationType($1); printf("\n Regla 52: variable_type: INT_TYPE \n");}
  | FLOAT_TYPE {saveIdentifierDeclarationType($1); printf("\n Regla 53: variable_type: FLOAT_TYPE \n");}
  | STRING_TYPE {saveIdentifierDeclarationType($1); printf("\n Regla 54: variable_type: STRING_TYPE \n");}
  ;
variable_list: variable_list SEMICOLON ID {validateIdDeclaration($3); insertIdentifier($3); printf("\n Regla 55: variable_list: variable_list SEMICOLON ID \n");} 
  | ID {validateIdDeclaration($1); insertIdentifier($1); printf("\n Regla 56: variable_list: ID \n");}
  ;


%%

int main(int argc, char *argv[]) {
	yyin = fopen(argv[1], "r");
  yydebug = 0;
  printf("STARTING COMPILATION\n");
  symbolTable = NULL;
	do {
		yyparse();
	} while(!feof(yyin));
  printTable();
  saveTable();
  printf("\n --- INTERMEDIA --- \n");
  ast treeCopy = *tree;
  printAndSaveAST(tree);
  printf("\n\n\n ASSEMBLER HERE \n\n\n");
  generateAssembler(treeCopy);
	return 0;
}
void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s on line %d\n", s, yylineno);
	exit(1);
}

void saveIdentifierDeclarationType(char* identiferName) {
  strcpy(currentIdentifierDeclarationType, identiferName);
}

void validateIdIsDeclared(char* id) {
  symbolNode* symbol = findSymbol(id);
  if (symbol == NULL || strcmp(symbol->type, "") == 0) {
    fprintf(stderr, "\nVariable: %s is not declared on the declaration block on line %d\n", id, yylineno);
    exit(1);
  }
}

void compareIdentificators(char* firstIdentificator, char* secondIdentificator) {
  if (strcmp(firstIdentificator, secondIdentificator) != 0) {
    fprintf(stderr, "\n Identificators are not the same, line: %d\n", yylineno);
    exit(1);
  }
}

void validateIdDeclaration(char* id) {
  int i = 0;
  for(i = 0; i < seenIndex; i++) {
    if(strcmp(seen[i], id) == 0) {
      fprintf(stderr, "\n Identificator already declared, line: %d\n", yylineno);
    exit(1);
    }
  }
  
  seen[seenIndex] = strdup(id);
  seenIndex++;
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
        exit(1);
      }
    }
  }

  
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


