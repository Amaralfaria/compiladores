all:
	bison -d --output=sintatico_tab.c sintatico.y
	flex lexico.l
	gcc sintatico_tab.c lex.yy.c -o compilador -lfl
	./compilador brunov.cmi
