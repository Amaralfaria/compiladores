/* Verificando a sintaxe de programas segundo GLC-C-minus */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int num_linhas;

typedef enum {
    T_INTEIRO,
    T_VAZIO,
    T_ERRO,
} TipoDados;

typedef int bool;
#define true 1
#define false 0

/* Tabela de Símbolos */
struct symrec {
    char *name;             /* identificador */
    TipoDados tipo;
    struct symrec *next;    /* proximo item da lista */
};

typedef struct symrec symrec;

const char* tipo_para_string(TipoDados tipo) {
    switch (tipo) {
        case T_INTEIRO: return "inteiro";
        case T_VAZIO:    return "vazio";
        default:       return "DESCONHECIDO";
    }
}

/* ponteiro global para a tabela */
symrec *sym_table = (symrec *)0;

/* prototipos */
symrec *putsym(char *sym_name, TipoDados tipo);
symrec *getsym(char *sym_name);
void install(char *sym_name, TipoDados tipo);
TipoDados context_check(char *sym_name);
bool assegura_tipo_igual(int t1, int t2);
bool assegura_tipo_numerico(int t);
bool assegura_aritmetica(int t1, int t2);

/* funcao para inserir na tabela */
symrec *putsym(char *sym_name, TipoDados tipo) {
    symrec *ptr;
    ptr = (symrec *) malloc(sizeof(symrec));
    ptr->name = (char *) malloc(strlen(sym_name) + 1);
    strcpy(ptr->name, sym_name);
    ptr->next = (struct symrec *)sym_table;
    ptr->tipo = tipo;
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
void install(char *sym_name, TipoDados tipo) {
    symrec *s;
    s = getsym(sym_name);
    if (s == 0) {
        putsym(sym_name, tipo);
        printf("> Declaracao: '%s' do tipo %s registrado na tabela.\n", sym_name, tipo_para_string(tipo));
    } else {
        printf("Erro semântico: Identificador '%s' ja definido.\n", sym_name);
    }
}

bool assegura_aritmetica(int t1, int t2){
    if (!assegura_tipo_igual(t1, t2) || !assegura_tipo_numerico(t1) || !assegura_tipo_numerico(t2)) {
        return false;
    }
    return true;
}

bool assegura_tipo_igual(int t1, int t2){
    if (t1 == T_ERRO || t2 == T_ERRO) {
        return true;
    }

    if(t1 != t2) {
        printf("Erro Semântico (linha %d): Tipos incompatíveis! (Esperava tipos iguais)\n", num_linhas);
        return false;
    }
    return true;
}

bool assegura_tipo_numerico(int t) {
    if (t == T_ERRO) {
        return true;
    }

    if (t != T_INTEIRO) {
        printf("Erro Semântico (linha %d): Operação aritmética requer tipo INTEIRO.\n", num_linhas);
        return false;
    }
    return true;
}

/* funcao para checar contexto */
TipoDados context_check(char *sym_name) {
    symrec *sym = getsym(sym_name);
    if (sym == 0) {
        printf("Erro semântico: Identificador '%s' nao declarado.\n", sym_name);
        return T_ERRO;
    } else {
        /* printf("> Uso: '%s' verificado com sucesso.\n", sym_name); */
    }
    return sym -> tipo;
}

%}

%union {
    char *cadeia;
    int tipo;
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

%type <tipo> especificador_de_tipo

%type <tipo> expressao
%type <tipo> var
%type <tipo> expressao_simples
%type <tipo> expressao_aditiva
%type <tipo> termo
%type <tipo> fator
%type <tipo> chamada

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
        install($2, $1); 
    } 
;
especificador_de_tipo: INTEIRO 				{$$ = T_INTEIRO;}
	| VAZIO						{$$ = T_VAZIO;}
;
declaracao_de_funcao: especificador_de_tipo ID '(' params ')' comando_composto { 
        install($2, $1); 
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
        install($2, $1); 
    }
    | especificador_de_tipo ID '[' ']'
    {
        install($2, $1); 
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
expressao: var '=' expressao				
    {
        assegura_tipo_igual($1, $3);
        $$ = $1;
    }
    | expressao_simples			{$$ = $1;}
;
var: ID 
    { 
        $$ = context_check($1); 
    }
;
expressao_simples: expressao_aditiva relop expressao_aditiva			
    {        
        assegura_aritmetica($1, $3);
        $$ = T_INTEIRO;       
    }
    | expressao_aditiva			{$$ = $1;}
;
relop: LE{;}
	| GE						{;}
	| EQ						{;}
	| NE						{;}
	| LT						{;}
	| GT						{;}
;
expressao_aditiva: expressao_aditiva operacao_add termo 
    {
        assegura_aritmetica($1, $3);
        $$ = T_INTEIRO;       
    }
    | termo					{$$ = $1;}
;

operacao_add: SOMA					{;}
	| SUB						{;}
;
termo: termo mulop fator				
    {
        assegura_aritmetica($1, $3);
        $$ = T_INTEIRO;
    }
	| fator						{$$ = $1;}
;
mulop: MUL						{;}
	| DIV						{;}
;
fator: NUM                       {$$ = T_INTEIRO;}
     | var                       {$$ = $1;} 
     | '(' expressao ')'         {$$ = $2;}
     | chamada                   {$$ = $1;} 
;
chamada: ID '(' args ')' 
    {
        $$ = context_check($1);
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


