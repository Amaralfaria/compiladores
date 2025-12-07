/* Analisador Lexico */
%{
  # include <string.h>
  # include "sintatico_tab.h"
%}
%%
inteiro		{return INTEIRO;}
vazio		{return VAZIO;}
se		{return SE;}
senao		{return SENAO;}
enquanto        {return ENQUANTO;}
retorna		{return RETORNA;}
"<="		{return LE;}
">="		{return GE;}
"=="		{return EQ;}
"!="		{return NE;}
"<"		{return LT;}
">"		{return GT;}
"+"		{return SOMA;}
"-"		{return SUB;}
"*"		{return MUL;}
"/"		{return DIV;}
[a-z]+      {
                yylval.cadeia = strdup(yytext); 
                return ID;
            }
[0-9]+		{return NUM;}
[ \t\n]*	{;}
.		{return yytext[0];}
%%
int yywrap() {
  return 1;
}