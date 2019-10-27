#include <stdlib.h>
#include <string.h>
#include <ctype.h> 
#include <stdio.h> 
#include "symbol.h"
#include "tree.h"


FILE *file;
int ifLabelCount;
int useSameIfLabel = 0;
int orWasHere = 0;
int repeatLabelCount = 0;
int insideInStatement = 0;


struct StackForStatements { 
    int top; 
    int* array; 
}; 

struct StackForOperators { 
    int top; 
    char array[5000][300]; 
}; 

struct StackForStatements* stackForIfs;
struct StackForStatements* stackForRepeats;
struct StackForOperators* stackOperators;

void generateAssembler(ast tree);
void initAssembler();
void insertSymbolsOnData();
void insertInitialCodeBlock();
void postOrder(ast* tree);
void processNode(ast* tree);
void stackCleanup();
void insertAuxiliarsOperands();
void pushOnStack();
int pop(struct StackForStatements* stack);
void push(struct StackForStatements* stack, int item);
char* popOperator();
void pushOperator(char* item);
char* getInstructionFor(char* op);
char* getRealInstructionFor(char* op);
void finishAssembler();
void assemblerRutines();

void generateAssembler(ast tree) {
    file = fopen("final.asm", "w");
    ifLabelCount = 0;
    repeatLabelCount = 0;
    insideInStatement = 0;
    stackForIfs = (struct StackForStatements*) malloc(sizeof(struct StackForStatements)); 
    stackForIfs->array = (int*) malloc(5000* sizeof(int)); 
    stackForRepeats = (struct StackForStatements*) malloc(sizeof(struct StackForStatements)); 
    stackForRepeats->array = (int*) malloc(5000* sizeof(int)); 
    stackOperators = (struct StackForOperators*) malloc(sizeof(struct StackForOperators)); 
    initAssembler();
    insertSymbolsOnData();
    insertAuxiliarsOperands();
    insertInitialCodeBlock();
    postOrder(&tree);
    finishAssembler();
    fclose(file);

}




void initAssembler() {
    fprintf(file,"include macros2.asm \n\n\n");
    fprintf(file,".MODEL LARGE\n");
    fprintf(file,".386\n");
    fprintf(file,".STACK 200h\n\n");
    fprintf(file,"MAXTEXTSIZE equ 40\n\n");
    fprintf(file,".DATA\n");
}

void insertSymbolsOnData() {
    symbolNode* current = symbolTable;
    while(current != NULL) {
        
        if (strcmp(current->type, "INT") == 0 || strcmp(current->type, "FLOAT") == 0) {
            fprintf(file,"\t%s dd ?\n", current->name);
        }

        if (strcmp(current->type, "STRING") == 0) {
           fprintf(file,"\t%s db MAXTEXTSIZE dup (?),'$'\n", current->name);
        }

        if (strcmp(current->type, "INTEGER_C") == 0) {
            fprintf(file,"\t%s dd %s.0\n", current->name, current->value);
        }

        if (strcmp(current->type, "FLOATT_C") == 0) {
            fprintf(file,"\t%s dd %s\n", current->name, current->value);
        }

        if (strcmp(current->type, "STRING_C") == 0) {
            fprintf(file,"\t%s db '%s','$', %d dup (?)\n", current->name, current->value, current->length);
        }
        
        current = current->next;
    }
    
}


void insertAuxiliarsOperands() {
    fprintf(file,"\t_SUM dd ?\n");
    fprintf(file,"\t_MINUS dd ?\n");
    fprintf(file,"\t_DIVIDE dd ?\n");
    fprintf(file,"\t_MULTIPLY dd ?\n");
    fprintf(file,"\t_AUXILIAR dd ?\n");

}

void insertInitialCodeBlock() {
    fprintf(file,"\n\n");
    fprintf(file,".code\n");
    
    fprintf(file,"\tbegin: .startup\n");
    
    fprintf(file,"\tmov AX,@DATA\n");
    fprintf(file,"\tmov DS,AX\n");
    fprintf(file,"\tmov ES,AX\n");
    fprintf(file,"\tfinit\n\n");

    assemblerRutines();
    fprintf(file,"\n\n");
}

void postOrder(ast* tree) {
    if (tree == NULL) 
    return; 

    if (strcmp(tree->value, "REPEAT") == 0) {
        fprintf(file,"\nLABEL_REPEAT_%d:\n", repeatLabelCount);
        push(stackForRepeats, repeatLabelCount);
        push(stackForRepeats, repeatLabelCount);
        repeatLabelCount++;
    }

    if (strcmp(tree->value, "IF") == 0) {
        ifLabelCount++;
    }

    postOrder(tree->left); 

    if (strcmp(tree->value, "AND") == 0) {
        char* op = popOperator();
        useSameIfLabel = 1;
        fprintf(file, "\n\t%s LABEL_IF_%d\n", getInstructionFor(op),ifLabelCount);
        push(stackForIfs, ifLabelCount);
        stackCleanup();
    }

    if (strcmp(tree->value, "OR") == 0) {
        char* op = popOperator();
        useSameIfLabel = 0;
        //PARCHE: Habria que ver porque op esta null.
        if (!op && strcmp(op, ">=") == 0) {
            fprintf(file, "\n\tJGE LABEL_IF_%d\n", ifLabelCount);
        }
        push(stackForIfs, ifLabelCount);
        stackCleanup();
        orWasHere = 1;
    }

    if (strcmp(tree->value, "IF") == 0) {
        char* op = popOperator();
        if (useSameIfLabel != 1) {
            ifLabelCount++;
        } else {
            useSameIfLabel = 0;
        }
        
        fprintf(file, "\n\t%s LABEL_IF_%d\n", getInstructionFor(op),ifLabelCount);
        
        if (orWasHere == 1) {
            fprintf(file,"LABEL_IF_%d:\n", pop(stackForIfs));
            orWasHere = 0;
        }
        push(stackForIfs, ifLabelCount);
    }

    if (strcmp(tree->value, "REPEAT") == 0) {
        int value = pop(stackForRepeats);
        char* op = popOperator();
        if(!op) // PARCHE: Habria que ver porque op esta null.
            fprintf(file,"\n\t%s LABEL_REPEAT_OUT_%d\n", getInstructionFor(op), value);
    }

    

    postOrder(tree->right); 

    if (strcmp(tree->value, "REPEAT") == 0) {
        int value = pop(stackForRepeats);
        fprintf(file,"\n\t%JMP LABEL_REPEAT_%d\n", value);
        fprintf(file,"\nLABEL_REPEAT_OUT_%d:\n", value);
    }

    printf("%s ", tree->value);
    processNode(tree);
}

void processNode(ast* tree) {
    if (strcmp(tree->value, "=") == 0) {
        fprintf(file,"\n\t; ASIGNACION \n");
        if (strcmp(tree->right->value, "_SUM") != 0 && strcmp(tree->right->value, "_MINUS") != 0 && strcmp(tree->right->value, "_MULTIPLY") != 0 && strcmp(tree->right->value, "_DIVIDE") != 0) {
            symbolNode* symbol = findSymbol(tree->right->value);
            if(symbol != NULL && symbol->length > 0) {
                fprintf(file,"\tLEA SI, %s\n", tree->right->value); 
                fprintf(file,"\tLEA DI,%s\n", tree->left->value);
                fprintf(file,"\tCALL COPY\n");
                return;
            }
        }
        
        

        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFSTP %s\n", tree->left->value);
    }

    if (strcmp(tree->value, "+") == 0) {
        fprintf(file,"\n\t; SUMA \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFADD\n");
        tree->value = "_SUM";
        fprintf(file,"\tFSTP %s\n", tree->value);
        stackCleanup();
    }

    if (strcmp(tree->value, "-") == 0) {
        fprintf(file,"\n\t; RESTA \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFSUB\n");
        tree->value = "_MINUS";
        fprintf(file,"\tFSTP %s\n", tree->value);
        stackCleanup();
    }

    if (strcmp(tree->value, "*") == 0) {
        fprintf(file,"\n\t; MULTIPLICA \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFMUL\n");
        tree->value = "_MULTIPLY";
        fprintf(file,"\tFSTP %s\n", tree->value);
        stackCleanup();
    }

    if (strcmp(tree->value, "/") == 0) {
        fprintf(file,"\n\t; DIVIDE \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFDIV\n");
        tree->value = "_DIVIDE";
        fprintf(file,"\tFSTP %s\n", tree->value);
        stackCleanup();
    }

    if (strcmp(tree->value, ">=") == 0) {
        fprintf(file,"\n\t; => \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFCOM");
        pushOperator(">=");
        
    }

    if (strcmp(tree->value, "<=") == 0) {
        fprintf(file,"\n\t; <= \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFCOM");
        pushOperator("<=");
        
    }

    if (strcmp(tree->value, ">") == 0) {
        fprintf(file,"\n\t; > \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFCOM");
        pushOperator(">");
        
    }

    if (strcmp(tree->value, "<") == 0) {
        fprintf(file,"\n\t; < \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFCOM");
        pushOperator("<");
        
    }

    if (strcmp(tree->value, "==") == 0) {
        fprintf(file,"\n\t; == \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFCOM");
        pushOperator("==");
        
    }

    if (strcmp(tree->value, "!=") == 0) {
        fprintf(file,"\n\t; != \n");
        fprintf(file,"\tFLD %s\n", tree->left->value);
        fprintf(file,"\tFLD %s\n", tree->right->value);
        fprintf(file,"\tFCOM");
        pushOperator("!=");
        
    }

    if (strcmp(tree->value, "IF") == 0) {
        fprintf(file,"LABEL_IF_%d:\n", pop(stackForIfs));
        ifLabelCount++;
        stackCleanup();
    }

    if (strcmp(tree->value, "PRINT") == 0) {
        fprintf(file,"\n\t; PRINT\n");
        fprintf(file,"\tdisplayString %s\n", tree->left->value);
    }


    if (strcmp(tree->value, "READ") == 0) {
        fprintf(file,"\n\t; READ\n");
        fprintf(file, "\tgetString %s\n", tree->left->value);
    }
    
}


void stackCleanup() {
     fprintf(file, "\n\t; STACK CLENUP\n"); 
     fprintf(file, "\tFFREE st(0)\n");
     fprintf(file, "\tFFREE st(1)\n");
     fprintf(file, "\tFFREE st(2)\n");
     fprintf(file, "\tFFREE st(3)\n");
     fprintf(file, "\tFFREE st(4)\n");
     fprintf(file, "\tFFREE st(5)\n");
     fprintf(file, "\tFFREE st(6)\n");
     fprintf(file, "\tFFREE st(7)\n");
     fprintf(file, "\n");
}

int pop(struct StackForStatements* stack) { 
    return stack->array[stack->top--]; 
}


void push(struct StackForStatements* stack, int item) { 
    stack->array[++stack->top] = item; 
} 

char* popOperator() { 
    return stackOperators->array[stackOperators->top--]; 
}


void pushOperator(char* item) { 
    strcpy(stackOperators->array[++stackOperators->top],item); 
} 


char* getInstructionFor(char* op) {
    if (strcmp(op, ">=") == 0) {
            return "JL";
    }

    if (strcmp(op, ">") == 0) {
            return "JLE";
    }

    if (strcmp(op, "<=") == 0) {
            return "JG";
    }

    if (strcmp(op, "<") == 0) {
            return "JGE";
    }

    if (strcmp(op, "==") == 0) {
            return "JNE";
    }

    if (strcmp(op, "!=") == 0) {
            return "JE";
    }
    return ""; // PARCHE: Solucion temporal, pero en realidad no tendria que estar jaja.
}

char* getRealInstructionFor(char* op) {
    if (strcmp(op, ">=") == 0) {
            return "BGE";
    }

    if (strcmp(op, ">") == 0) {
            return "JG";
    }

    if (strcmp(op, "<=") == 0) {
            return "JLE";
    }

    if (strcmp(op, "<") == 0) {
            return "JL";
    }

    if (strcmp(op, "==") == 0) {
            return "JE";
    }

    if (strcmp(op, "!=") == 0) {
            return "JNE";
    }
}


void finishAssembler() {
    fprintf(file,"\n\n\n\t; END PROGRAM \n\n");
    fprintf(file,"\tmov AX, 4C00h\n");
    fprintf(file,"\tint 21h\n");
   
    fprintf(file,"END begin\n");
}

void assemblerRutines() {

    fprintf(file, "\n\n\t; ROUTINES\n");
    fprintf(file, "STRLEN PROC\n");
    fprintf(file, "\tmov bx,0\n");
    fprintf(file, "STRL01:\n");
    fprintf(file, "\tcmp BYTE PTR [SI+BX],'$'\n");
    fprintf(file, "\tje STREND\n");
    fprintf(file, "\tinc BX\n");
    fprintf(file, "\tcmp BX, MAXTEXTSIZE\n");
    fprintf(file, "\tjl STRL01\n");
    fprintf(file, "STREND:\n");
    fprintf(file, "\tret\n");
    fprintf(file, "STRLEN ENDP\n\n");


    fprintf(file, "COPY PROC\n");
    fprintf(file, "\tcall STRLEN\n");
    fprintf(file, "\tcmp bx,MAXTEXTSIZE\n");
    fprintf(file, "\tjle COPYSIZEOK\n");
    fprintf(file, "\tmov bx,MAXTEXTSIZE\n");
    fprintf(file, "COPYSIZEOK:\n");
    fprintf(file, "\tmov cx,bx\n");
    fprintf(file, "\tcld\n");
    fprintf(file, "\trep movsb\n");
    fprintf(file, "\tmov al,'$'\n");
    fprintf(file, "\tmov BYTE PTR [DI],al\n");
    fprintf(file, "\tret\n");
    fprintf(file, "COPY ENDP\n\n");
} 