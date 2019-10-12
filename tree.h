#include <stdlib.h>
#include <string.h>
#include <ctype.h> 
#include <stdio.h> 

// Ast stands for Abstract Syntax Tree

void printAndSaveAST();
void printAST();

typedef struct treeNode {
    char* value;
    struct treeNode* left;
    struct treeNode* right;
} ast;


FILE *file;


ast* newNode(char* operation, ast* leftNode, ast* rightNode) {
    ast* node = (ast*) malloc(sizeof(ast));
    node->value = operation;
    node->left = leftNode;
    node->right = rightNode;
    return node;
}


ast* newLeaf(char* value) {
    ast* node = (ast*) malloc(sizeof(ast));
   
    node->value = strdup(value);
    node->left = NULL;
    node->right = NULL;
    return node;
}

void printAST(ast* tree) { 
     if (tree == NULL) 
          return; 
  
     /* first recur on left child */
     printAST(tree->left); 
  
     /* then print the data of node */
     printf("%s ", tree->value);
     fprintf(file, "%s ", tree->value);
  
     /* now recur on right child */
     printAST(tree->right); 
} 


void printAndSaveAST(ast* tree) {
    ast* copy = tree;
    file = fopen("intermedia.txt", "w");
    if (file == NULL)
    {
        printf("Error opening file!\n");
        exit(1);
    }

    printAST(copy);
    fclose(file);
}