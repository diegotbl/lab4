#include<stdio.h>
#include<stdlib.h>

int main(){
  char l[30];
  char y[30];
  char dat[30];
  char cmd[35];
  char saida[30];

  printf("Digite o nome do arquivo .l: \n");
  scanf("%s", &l);
  printf("Digite o nome do arquivo .y: \n");
  scanf("%s", &y);
  printf("Digite o nome do arquivo de dados .dat (caso nao haja digite n): \n");
  scanf("%s", &dat);

  strcpy(saida, "saida");
  strcat(l, ".l");
  strcat(y, ".y");
  strcat(dat, ".dat");

  printf("\nflex %s\n", l);
  sprintf(cmd, "flex %s", l);
  system(cmd);
  printf("yacc %s\n", y);
  sprintf(cmd, "yacc %s", y);
  system(cmd);
  printf("gcc y.tab.c main.c yyerror.c -o %s -lfl\n", saida);
  sprintf(cmd, "gcc y.tab.c main.c yyerror.c -o %s -lfl", saida);
  system(cmd);

  if (!strcmp(dat, "n.dat")) {
    printf("%s > ppp\n", saida);
    sprintf(cmd, "%s > ppp", saida);
    system(cmd);
  } else {
    printf("%s < %s > ppp\n", saida, dat);
    sprintf(cmd, "%s < %s > ppp", saida, dat);
    system(cmd);
  }
  printf("\n");
  printf("more ppp\n\n");
  system("more ppp");
}
