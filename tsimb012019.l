%{
void comentario (void);
char tratachar (char *);
%}
delim			    [ \t\n\r]
ws				    {delim}+
digito		    [0-9]
letra			    [A-Za-z]
ctint			    {digito}+
id				    {letra}({letra}|{digito})*
ctreal		    {digito}+\.{digito}*([Ee][+-]?{digito}+)?
carac1		    \\.|[^\\']
ctcarac		    '{carac1}'
%%
{ws}			    { ;}
"/*"			    {comentario ();}
char			    {return CHAR;}
false			    {return FALSE;}
float			    {return FLOAT;}
int			      {return INT;}
local			    {return LOCAL;}
logic			    {return LOGIC;}
program			  {return PROGRAM;}
statements    {return STATEMENTS;}
true		      {return TRUE;}
{id}			    {strcpy (yylval.cadeia, yytext); return ID;}
{ctcarac}	    {yylval.carac = tratachar (yytext); return CHARCT;}
{ctint}		    {yylval.valint = atoi(yytext); return INTCT;}
{ctreal}		  {yylval.valreal = atof(yytext); return FLOATCT;}
"||"			    {return OR;}
"&&"			    {return AND;}
"!"			      {return NOT;}
"<"		    	  {yylval.atr = LT; return RELOP;}
"<="			    {yylval.atr = LE; return RELOP;}
">"		    	  {yylval.atr = GT; return RELOP;}
">="			    {yylval.atr = GE; return RELOP;}
"="		        {yylval.atr = EQ; return RELOP;}
"!="			    {yylval.atr = NE; return RELOP;}
"+"		    	  {yylval.atr = MAIS; return ADOP;}
"-"	    		  {yylval.atr = MENOS; return ADOP;}
"*"	    		  {yylval.atr = MULT; return MULTOP;}
"/"		    	  {yylval.atr = DIV; return MULTOP;}
"%"		    	  {yylval.atr = RESTO; return MULTOP;}
"~"		    	  {return NEG;}
"("		    	  {return OPPAR;}
")"		    	  {return CLPAR;}
"{"		    	  {return OPBRACE;}
"}"		    	  {return CLBRACE;}
";"		    	  {return SCOLON;}
":"		    	  {return COLON;}
","		    	  {return COMMA;}
"<-"			    {return ASSIGN;}
.				      {yylval.carac = yytext[0]; return INVAL;}
%%

/*    comentario: le e descarta os comentarios do programa    */
void comentario () {
	char c;
  int estado = 1;

	while (estado != 3) {
		switch (estado) {
			case 1:
				c = input ();
				if (c == EOF) estado = 3;
				else if (c == '*') estado = 2;
				break;
			case 2:
				c = input ();
				if (c == EOF || c == '/') estado = 3;
				else if (c != '*') estado = 1;
		}
	}
}

/*
	tratachar: retorna o codigo ASCII de uma constante do tipo char,
  eliminando os apostrofos e as barras invertidas
*/
char tratachar (char *s) {
	if (s[1] != '\\')
    return s[1];
	else switch (s[2]) {
		case 'a': 	return 7;
    case '\\': 	return 92;
		case 'b': 	return 8;
    case 'r': 	return 13;
		case '\"': 	return 34;
    case 'f': 	return 12;
		case 't': 	return 9;
    case 'n': 	return 10;
		case '0': 	return 0;
    case '\'': 	return 39;
		case 'v': 	return 11;
		default:  	return s[2];
	}
}
