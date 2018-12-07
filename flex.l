space " "
newline "\n"
char [a-zA-Z]
digit [0-9]
special [$_@]
Datatype "integer_"|"double_"|"character_"|"void_"
Operator "equal_operator_"|"add_operator_"|"minus_operator_"|"divide_operator_"|"mult_operator_"|"AND_operator_"|"OR_operator_"|"modulas_operator_"
Relational_Operator "greater_than_"|"less_than_"|"greater_equal_"|"less_equal_"|"relational_and_"|"relational_or_"|"relational_equal_"|"relational_not_equal_"

%{
	#include "bison.tab.h"
	#include <string.h>
%}



%%
{space}|{newline} {}
"#".*"#" {/*This is comment*/}
";" {return SM;}
"," {return CM;}
{digit}+ 	{
				yylval.val = atoi(yytext);
				return NUM;
			}

"Func_Main" { return MAIN;}
"Func_PrintVariable" { return PRINTVAR;}
"Func_PrintString" {return PRINTSTR;}
"Func_PrintNewLine" {return PRINTLN;}

"Func_"({char}|{digit}|{special})+ {return FUNCTION;}

"variable_"({char}|{digit}|{special})+ { strcpy(yylval.text,yytext);return ID;}

"integer_" {  return INT;}
"double_" { return DOUBLE;}
"character_" { return CHAR;}

"PB" { return PB;}
"PE" { return PE;}

"Block_Begin" { return BB;}
"Block_End" { return BE;}

"equal_operator_" {return ASGN;}
"add_operator_" {return PLUS;}
"minus_operator_" {return MINUS;}
"mult_operator_" {return MULT;}
"divide_operator_" {return DIV;}
"less_than_" {return LT;}
"greater_than_" {return GT;}
"less_equal_" {return LE;}
"greater_equal_" {return GE;}

"ElseIf" {return ELSEIF;}
"If" { return IF;}
"Else" {return ELSE;}

"For" {return FOR;}
"IncrementBy" {return INC;}
"To" {return TO;}

"Switch" {return SWITCH;}
"*" {return DEFAULT;}
":" {return COL;}
. {}


"\""(.)*"\"" {strcpy(yylval.text,yytext);return STR;}




%%


int yywrap()
{
	return 1;
}


int main(){
	yyin = freopen("sample_in.txt","r",stdin);
	yyout= freopen("sample_out.txt","w",stdout);
	yyparse();
}