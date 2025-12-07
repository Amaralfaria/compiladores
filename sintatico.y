/* Verificando a sintaxe de programas segundo GLC-C-minus */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Tabela de Símbolos */
struct symrec {
    char *name;             /* identificador */
    struct symrec *next;    /* proximo item da lista */
};

typedef struct symrec symrec;

/* ponteiro global para a tabela */
symrec *sym_table = (symrec *)0;

/* prototipos */
symrec *putsym(char *sym_name);
symrec *getsym(char *sym_name);
void install(char *sym_name);
void context_check(char *sym_name);

/* funcao para inserir na tabela */
symrec *putsym(char *sym_name) {
    symrec *ptr;
    ptr = (symrec *) malloc(sizeof(symrec));
    ptr->name = (char *) malloc(strlen(sym_name) + 1);
    strcpy(ptr->name, sym_name);
    ptr->next = (struct symrec *)sym_table;
    sym_table = ptr;
    return ptr;
}

/* funcao para buscar na tabela */
symrec *getsym(char *sym_name) {
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next)
        if (strcmp(ptr->name, sym_name) == 0)
            return ptr;
    return 0;
}

/* funcao para declaracao */
void install(char *sym_name) {
    symrec *s;
    s = getsym(sym_name);
    if (s == 0) {
        putsym(sym_name);
        printf("> Declaracao: '%s' registrado na tabela.\n", sym_name);
    } else {
        printf("Erro semântico: Identificador '%s' ja definido.\n", sym_name);
    }
}

/* funcao para checar contexto */
void context_check(char *sym_name) {
    if (getsym(sym_name) == 0) {
        printf("Erro semântico: Identificador '%s' nao declarado.\n", sym_name);
    } else {
        /* printf("> Uso: '%s' verificado com sucesso.\n", sym_name); */
    }
}

%}

%union {
    char *cadeia;
}

%token INTEIRO
%token VAZIO
%token <cadeia> ID
%token NUM
%token SE
%token SENAO
%token ENQUANTO
%token RETORNA
%token LE
%token GE
%token EQ
%token NE
%token LT
%token GT
%token SOMA
%token SUB
%token MUL
%token DIV


%left '='
%left EQ NE
%left LT GT LE GE
%left SOMA SUB
%left MUL DIV
%%

/* Regras definindo a GLC e acoes correspondentes */
/* neste nosso exemplo quase todas as acoes estao vazias */
programa:	lista_de_declaracoes			{printf("Blz de programa sintaticamente correto!");}
;
lista_de_declaracoes: lista_de_declaracoes declaracao {;}
                    | declaracao                      {;}
;
declaracao: declaracao_de_var 				{;}
	| declaracao_de_funcao				{;}
;
declaracao_de_var: especificador_de_tipo ID ';' 
    { 
        /* instalar na tabela de simbolos */
        install($2); 
    } 
;
especificador_de_tipo: INTEIRO 				{;}
	| VAZIO						{;}
;
declaracao_de_funcao: especificador_de_tipo ID '(' params ')' comando_composto { 
        install($2); 
    }
;
params: lista_params {;}
      | VAZIO        {;}
;
lista_params: lista_params ',' param {;}
            | param                  {;}
;
param: especificador_de_tipo ID 
    { 
        install($2); 
    }
    | especificador_de_tipo ID '[' ']'
    {
        install($2);
    }
;
comando_composto: '{' declaracoes_locais lista_de_comandos '}'	{;}
;
declaracoes_locais: declaracoes_locais declaracao_de_var {;}
                  | /* vazio */                          {;}
;
lista_de_comandos: lista_de_comandos comando {;}
                 | /* vazio */               {;}
;
comando: comando_de_expressao			{;}
	| comando_de_selecao				{;}
	| comando_de_iteracao				{;}
	| comando_de_retorno				{;}
	| comando_composto        			{;}
		
;
comando_de_expressao: expressao ';'			{;}
;
comando_de_selecao: SE '(' expressao ')' comando		{;}
		| SE '(' expressao ')' comando SENAO comando	{;}
;
comando_de_iteracao: ENQUANTO '(' expressao ')' comando {;}
;
comando_de_retorno: RETORNA ';'				{;}
	| RETORNA expressao ';'				{;}
;
expressao: var '=' expressao				{;}
		| expressao_simples			{;}
;
var: ID 
    { 
        context_check($1); 
    }
;
expressao_simples: expressao_aditiva relop expressao_aditiva			{;}
		| expressao_aditiva			{;}
;
relop: LE{;}
	| GE						{;}
	| EQ						{;}
	| NE						{;}
	| LT						{;}
	| GT						{;}
;
expressao_aditiva: expressao_aditiva operacao_add termo {;}
		| termo					{;}
;

operacao_add: SOMA					{;}
	| SUB						{;}
;
termo: termo mulop fator				{;}
	| fator						{;}
;
mulop: MUL						{;}
	| DIV						{;}
;
fator: NUM                       {;}
     | var                       {;} 
     | '(' expressao ')'         {;}
     | chamada                   {;} 
;
chamada: ID '(' args ')' 
    {
         context_check($1);
    }
;
args: lista_args  {;}
    | /* vazio */ {;}
;

lista_args: lista_args ',' expressao {;}
          | expressao                {;}
;
%%
main(argc, argv)
int argc;
char **argv;
{
	extern FILE *yyin;
	extern FILE *yyout;

	++argv; --argc; 	    /* abre arquivo de entrada se houver */
	if(argc > 0)
		yyin = fopen(argv[0],"rt");
	else
		yyin = stdin;    /* cria arquivo de saida se especificado */
	if(argc > 1)
		yyout = fopen(argv[1],"wt");
	else
		yyout = stdout;

	yyparse ();

	fclose(yyin);
	if (yyout) fclose(yyout);
}
yyerror (s)
    char *s;
{
    printf ("Problema com a analise sintatica: %s\n", s);
}


