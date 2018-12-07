/* C Declarations */

 %{
	#include<stdio.h>
	#include<stdlib.h>
	#include <string.h>

	int ifswitchdone = 0;
	int switchvariable;

	int ifval[1000];
	int ifpointer = -1;
	int ifdone[1000];

    int pointer = 0;
    int value[1000];
    char varListArray[1000][1000];

    ///if already declared  return 1 else return 0
    int isdeclared(char str[]){
        int i;
        for(i = 0; i < pointer; i++){
            if(strcmp(varListArray[i],str) == 0) return 1;
        }
        return 0;
    }
    /// if already declared return 0 or add new value and return 1;
    int addnewval(char str[],int val){
        if(isdeclared(str) == 1) return 0;
        strcpy(varListArray[pointer],str);    //add variable to array
        value[pointer] = val;            //storing of variables
        pointer++;
        return 1;
    }

    ///get the value of corresponding string
    int getval(char str[]){
        int index = -1;
        int i;
        for(i = 0; i < pointer; i++){
            if(strcmp(varListArray[i],str) == 0) {
                index = i;
                break;
            }
        }
        return value[index];
    }
    int setval(char str[], int val){
    	int index = -1;
        int i;
        for(i = 0; i < pointer; i++){
            if(strcmp(varListArray[i],str) == 0) {
                index = i;
                break;
            }
        }
        value[index] = val;

    }


%}

%union {
  char text[1000];
  int val;
}


%token <text>  ID
%token <val>  NUM
%token <text> STR

%type <val> expression

%left LT GT LE GE
%left PLUS MINUS
%left MULT DIV



%token INT DOUBLE CHAR MAIN PB PE BB BE SM CM ASGN PRINTVAR PRINTSTR PRINTLN PLUS MINUS MULT DIV LT GT LE GE IF ELSE ELSEIF FOR INC TO SWITCH DEFAULT COL FUNCTION
%nonassoc IFX
%nonassoc ELSE
%left SH


%%

starthere 	: function program { printf("\nCompilation Successful\n"); }
			;

program		: INT MAIN PB PE BB statement BE 
			;
statement	: /* empty */
			| statement declaration
			| statement print
			| statement expression 
			| statement ifelse
			| statement assign
			| statement forloop
			| statement switch
			;




declaration : type variables SM 
			;
type		: INT | DOUBLE | CHAR 
			;
variables	: variable CM variables 
			| variable 
			;
variable   	: ID 	
					{
						//printf("%s\n",$1);
						int x = addnewval($1,0);
						if(!x) {
							printf("Compilation Error:Variable %s is already declared\n",$1);
							exit(-1);
						}

					}
			| ID ASGN expression 	
					{
						//printf("%s %d\n",$1,$3);
						int x = addnewval($1,$3);
						if(!x) {
							printf("Compilation Error: Variable %s is already declared\n",$1);
							exit(-1);
							}
					}

			;


assign : ID ASGN expression SM  
					{
						if(!isdeclared($1)) {
							printf("Compilation Error: Variable %s is not declared\n",$1);
							exit(-1);
						}
						else{
							setval($1,$3);
						}
				    }


print		: PRINTVAR PB ID PE SM 	
					{
						if(!isdeclared($3)){
							printf("Compilation Error: Variable %s is not declared\n",$3);
							exit(-1);
						}
						else{
							int v = getval($3);
							printf("Printed variable: %d\n",v);
						}
					}
			| PRINTSTR PB STR PE SM 
					{
						int lentgh = strlen($3);
						int i;
						printf("Printed string:");
						for(i = 1;  i < lentgh-1; i++) printf("%c",$3[i]);
						printf("\n");
					}
			| PRINTLN PB PE	SM 	
					{
						printf("Printing a new line: \n");
					}
			;


expression : NUM {$$ = $1;}
			| ID 	
					{
						if(!isdeclared($1)) {
							printf("Compilation Error: Variable %s is not declared\n",$1);
							exit(-1);
						}
						else{
							$$ = getval($1);
						}
				 	}
			| expression PLUS expression 
					{$$ = $1 + $3;}
			| expression MINUS expression 
					{$$ = $1 - $3;}
			| expression MULT expression 
					{$$ = $1 * $3;}
			| expression DIV expression 
					{
						if($3) {
 							$$ = $1 / $3;
							}
				  		else {
							$$ = 0;
							printf("\nRuntime Error: division by zero\t");
							exit(-1);
				  		} 
					}
			| expression LT expression	
					{ $$ = $1 < $3; }
			| expression GT expression	
					{ $$ = $1 > $3; }
			| expression LE expression	
					{ $$ = $1 <= $3; }
			| expression GE expression	
					{ $$ = $1 >= $3; }
			| PB expression PE
					{$$ = $2;}
			;

ifelse 	: IF PB ifexp PE BB statement BE elseif
					{

						ifdone[ifpointer] = 0;
						ifpointer--;
					}
		;
ifexp	: expression 
					{
						ifpointer++;
						ifdone[ifpointer] = 0;
						if($1){
							printf("\nIf executed\n");
							ifdone[ifpointer] = 1;
						}
					}
		;
elseif 	: /* empty */
		| elseif ELSEIF PB expression PE BB statement BE 
					{
						if($4 && ifdone[ifpointer] == 0){
							printf("\nElse if block expression %d executed\n",$4);
							ifdone[ifpointer] = 1;
						}
					}
		| elseif ELSE BB statement BE
					{
						if(ifdone[ifpointer] == 0){
							printf("\nElse block executed\n");
							ifdone[ifpointer] = 1;
						}
					}

		;



forloop	: FOR PB expression TO expression INC expression PE BB statement BE 	
					{
						int startfrom = $3;
						int endin = $5;
						int difference = $7;
						int loop_count = 0;
						int k = 0;
						for(k = startfrom; k <= endin; k += difference){
							loop_count++;
						}	
						printf("Loop executes for %d times.\n",loop_count);
					}


switch	: SWITCH PB expswitch PE BB switchinside BE 
		;

expswitch 	:  expression 
					{
						ifswitchdone = 0;
						switchvariable = $1;
					}
			;


switchinside	: /* empty */
				| switchinside expression COL BB statement BE 
					{
						if($2 == switchvariable){
							printf("Executed switch variable: %d\n",$2);
							ifswitchdone = 1;
						}					
					}
				| switchinside DEFAULT COL BB statement BE 
					{
						if(ifswitchdone == 0){
							ifswitchdone = 1;
							printf("Default Block executed\n");
						}
					}
				;


function 	: /* empty */
			| function func
			;

func 	: type FUNCTION PB fparameter PE BB statement BE
					{
						printf("Function Declared\n");
					}
		;
fparameter 	: /* empty */
			| type ID fsparameter
			;
fsparameter : /* empty */
			| fsparameter CM type ID
			;

%%


int yyerror(char *s){
	printf( "%s\n", s);
}
