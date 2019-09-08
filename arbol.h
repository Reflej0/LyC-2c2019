#include <stdlib.h>
#include <string.h>
#include <ctype.h> 
#include <stdio.h> 

// Ast = Arbol Sintactico Abstracto

void imprimirGuardarAST();
void imprimirAST();

typedef struct NodoArbol 
{
    char* valor;
    struct NodoArbol* izquiedo;
    struct NodoArbol* derecho;
} ast;


FILE *file;


ast* crearNodo(char* operation, ast* nodoIzquierdo, ast* nodoDerecho) 
{
    ast* node = (ast*) malloc(sizeof(ast));
    node->valor = operation;
    node->izquiedo = nodoIzquierdo;
    node->derecho = nodoDerecho;
    return node;
}


ast* crearHoja(char* valor) 
{
    ast* node = (ast*) malloc(sizeof(ast));
   
    node->valor = strdup(valor);
    node->izquiedo = NULL;
    node->derecho = NULL;
    return node;
}

void imprimirAST(ast* tree) 
{ 
     if (tree == NULL) 
          return; 
  
     /* Recursividad por la izquierda */
     imprimirAST(tree->izquiedo); 
  
     /* Imprimir el valor del nodo */
     printf("%s ", tree->valor);
     fprintf(file, "%s ", tree->valor);
  
     /* recursividad por la derecha */
     imprimirAST(tree->derecho); 
} 


void imprimirGuardarAST(ast* tree) 
{
    ast* copy = tree;
    file = fopen("intermedia.txt", "w");
    if (file == NULL)
    {
        printf("Error en apertura de archivo!\n");
        exit(1);
    }

    imprimirAST(copy);
    fclose(file);
}