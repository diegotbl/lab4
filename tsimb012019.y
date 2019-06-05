%{
/* Inclusao de arquivos da biblioteca de C */
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

/* Definicao dos atributos dos atomos operadores */
#define 	LT         1
#define 	LE         2
#define		GT         3
#define		GE         4
#define		EQ         5
#define		NE         6
#define		MAIS       7
#define		MENOS      8
#define		MULT       9
#define		DIV        10
#define		RESTO      11

/*   Definicao dos tipos de identificadores   */
#define 	IDPROG     1
#define 	IDVAR      2

/*  Definicao dos tipos de variaveis   */
#define 	NAOVAR     0
#define 	INTEIRO    1
#define 	LOGICO     2
#define 	REAL       3
#define 	CARACTERE  4

/*   Definicao de outras constantes   */
#define   NCLASSHASH 23
#define   VERDADE    1
#define   FALSO      0

/*  Strings para nomes dos tipos de identificadores  */
char *nometipid[3] = {" ", "IDPROG", "IDVAR"};

/*  Strings para nomes dos tipos de variaveis  */
char *nometipvar[5] = {"NAOVAR", "INTEIRO", "LOGICO", "REAL", "CARACTERE"};

/*  Declaracoes para a tabela de simbolos  */
typedef struct celsimb celsimb;
typedef celsimb *simbolo;
struct celsimb {
	char *cadeia;
	int tid, tvar;
	char inic, ref;
	simbolo prox;
};

/*  Variaveis globais para a tabela de simbolos e analise semantica */
simbolo tabsimb[NCLASSHASH];
simbolo simb;

/*  Prototipos das funcoes para a tabela de simbolos e analise semantica  */
void InicTabSimb (void);
void ImprimeTabSimb (void);
simbolo InsereSimb (char *, int, int);
int hash (char *);
simbolo ProcuraSimb (char *);
void DeclaracaoRepetida (char *);
void TipoInadequado (char *);
void NaoDeclarado (char *);
%}

/* Definicao do tipo de yylval e dos atributos dos nao terminais */
%union {
	char cadeia[50];
	int atr, valint;
	float valreal;
	char carac;
}

/* Declaracao dos atributos dos tokens e dos nao-terminais */
%token    <cadeia>    ID
%token		<carac>     CHARCT
%token		<valint>		INTCT
%token		<valreal>   FLOATCT
%token		OR
%token		AND
%token		NOT
%token		<atr>       RELOP
%token		<atr>       ADOP
%token		<atr>       MULTOP
%token		NEG
%token		OPPAR
%token		CLPAR
%token		OPBRACE
%token		CLBRACE
%token		COMMA
%token		SCOLON
%token		COLON
%token		ASSIGN
%token		CHAR
%token		FALSE
%token		FLOAT
%token		INT
%token		LOCAL
%token		LOGIC
%token		PROGRAM
%token		STATEMENTS
%token		TRUE
%token		<carac>     INVAL
%%

/*  Producoes da gramatica:
	  Os terminais sao escritos e, depois de alguns,
	  para alguma estetica, ha mudanca de linha  */
Prog:	        {InicTabSimb();}  PROGRAM  ID  OPBRACE  {printf ("program %s {\n", $3);}
              Decls  Stats  CLBRACE  {printf ("}\n");}
    ;
Decls:
              |   LOCAL  COLON  {printf ("local :\n");}  DeclList
      ;
DeclList:	    Declaration  |  DeclList  Declaration
        ;
Declaration:  Type  ElemList  SCOLON  {printf (";\n");}
           ;
Type:       	INT  {printf ("int ");}
              |   FLOAT  {printf ("float ");}
              |   CHAR  {printf ("char ");}
              |   LOGIC  {printf ("logic ");}
    ;
ElemList:	    Elem
              |  ElemList  COMMA  {printf (", ");}  Elem
        ;
Elem:	        ID  {printf ("%s ", $1);}
    ;
Stats:        STATEMENTS  COLON  {printf ("statements :\n");}
              StatList
     ;
StatList:
              |   StatList  Statement
        ;
Statement:    CompStat
              |  AssignStat
         ;
CompStat:     OPBRACE  {printf ("{\n");}  StatList  CLBRACE {printf ("}\n");}
        ;
AssignStat:   Variable  ASSIGN  {printf ("<- ");}  Expression  SCOLON {printf (";\n");}
          ;
Expression:   AuxExpr1
              |  Expression  OR  {printf ("|| ");}  AuxExpr1
          ;
AuxExpr1:     AuxExpr2
              |  AuxExpr1  AND  {printf ("&& ");}  AuxExpr2
        ;
AuxExpr2:     AuxExpr3
              |  NOT  {printf ("! ");}  AuxExpr3
        ;
AuxExpr3:     AuxExpr4
              |   AuxExpr4  RELOP  {
                    switch ($2) {
                        case LT: printf ("< "); break;
                        case LE: printf ("<= "); break;
                        case EQ: printf ("= "); break;
                        case NE: printf ("!= "); break;
                        case GT: printf ("> "); break;
                        case GE: printf (">= "); break;
                    }
              }  AuxExpr4
        ;
AuxExpr4:     Term
              |  AuxExpr4  ADOP  {
                    switch ($2) {
                        case MAIS: printf ("+ "); break;
                        case MENOS: printf ("- "); break;
                    }
              }  Term
        ;
Term:         Factor
              |   Term  MULTOP  {
                    switch ($2) {
                        case MULT: printf ("* "); break;
                        case DIV: printf ("/ "); break;
                        case RESTO: printf ("%% "); break;
                    }
              }  Factor
    ;
Factor:       Variable
              |   INTCT  {printf ("%d ", $1);}
              |   FLOATCT  {printf ("%g ", $1);}
              |   CHARCT  {printf ("\'%c\' ", $1);}
            	|   TRUE  {printf ("true ");}
            	|   FALSE  {printf ("false ");}
            	|   NEG  {printf ("~ ");}  Factor
            	|   OPPAR  {printf ("( ");}  Expression  CLPAR  {printf (") ");}
      ;
Variable:     ID  {printf ("%s ", $1);}
        ;

%%

/* Inclusao do analisador lexico  */
#include "lex.yy.c"

/*  InicTabSimb: Inicializa a tabela de simbolos   */
void InicTabSimb () {
	int i;

	for (i = 0; i < NCLASSHASH; i++)
		tabsimb[i] = NULL;
}

/*
	ProcuraSimb (cadeia): Procura cadeia na tabela de simbolos;
	Caso ela ali esteja, retorna um ponteiro para sua celula;
	Caso contrario, retorna NULL.
*/
simbolo ProcuraSimb (char *cadeia) {
	simbolo s;
  int i;

	i = hash (cadeia);
	for (s = tabsimb[i] ; (s!=NULL) && strcmp(cadeia, s->cadeia) ; s = s->prox);

  return s;
}

/*
	InsereSimb (cadeia, tid, tvar): Insere cadeia na tabela de
	simbolos, com tid como tipo de identificador e com tvar como
	tipo de variavel; Retorna um ponteiro para a celula inserida
*/
simbolo InsereSimb (char *cadeia, int tid, int tvar) {
	int i;
  simbolo aux, s;

	i = hash (cadeia);
  aux = tabsimb[i];
	s = tabsimb[i] = (simbolo) malloc (sizeof (celsimb));
	s->cadeia = (char*) malloc ((strlen(cadeia)+1) * sizeof(char));
	strcpy (s->cadeia, cadeia);
	s->tid = tid;
  s->tvar = tvar;
	s->inic = FALSO;
  s->ref = FALSO;
	s->prox = aux;

  return s;
}

/*
	hash (cadeia): funcao que determina e retorna a classe
	de cadeia na tabela de simbolos implementada por hashing
*/
int hash (char *cadeia) {
	int i, h;

  for (h = i = 0; cadeia[i]; i++)
    h += cadeia[i];
	h = h % NCLASSHASH;

  return h;
}

/* ImprimeTabSimb: Imprime todo o conteudo da tabela de simbolos  */
void ImprimeTabSimb () {
	int i;
  simbolo s;

  printf ("\n\n   TABELA  DE  SIMBOLOS:\n\n");
	for (i = 0; i < NCLASSHASH; i++)
		if (tabsimb[i]) {
			printf ("Classe %d:\n", i);
			for (s = tabsimb[i]; s!=NULL; s = s->prox){
				printf ("  (%s, %s", s->cadeia,  nometipid[s->tid]);
				if (s->tid == IDVAR)
					printf (", %s, %d, %d", nometipvar[s->tvar], s->inic, s->ref);
				printf(")\n");
			}
    }
}

/*  Mensagens de erros semanticos  */
void DeclaracaoRepetida (char *s) {
	printf ("\n\n***** Declaracao Repetida: %s *****\n\n", s);
}

void NaoDeclarado (char *s) {
    printf ("\n\n***** Identificador Nao Declarado: %s *****\n\n", s);
}

void TipoInadequado (char *s) {
    printf ("\n\n***** Identificador de Tipo Inadequado: %s *****\n\n", s);
}
