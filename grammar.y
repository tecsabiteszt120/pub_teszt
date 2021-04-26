%{
    #include <iostream>
    #include <map>
    #include <string>
    using namespace std;
    int yylex();
    int yyerror(char* message){
        return 1;
    }

    map<string,int> identifiers;
%}

%union{
    int value;
    char name[16];
}

%token FREE TYPE HELP CALC
%token IF ELSE 
%token<value> NUMBER 
%token<name> ID

%type<value> term multiplication expression comparison num_vs_num num_vs_id id_vs_id id_vs_num

%%


commands: command '\n'  commands
        |
        ;

command:  help
        | CALC expression { cout<<"Result: "<<$2<<"\n"; }
        | get_val
        | declare 
        | setval
        | FREE ID {
            string tmp($2);
            if(identifiers.count(tmp)==1) {
                cout << "Variable '"<<tmp<<"' deleted!\n";
                identifiers.erase(identifiers.find(tmp));
                } 
            else{
                cout<<"No such variable\n"; }
            }
        | branch
        ;

get_val: ID {
            string tmp($1); 
            if(identifiers.count(tmp)==1)  {
            cout<<"'"<<tmp<<"' = "<<identifiers[tmp]<<"\n";
            }
            else{
                cout<<"'"<<tmp<<"' not declared!\n";
            }
        }

expression:   expression '+' multiplication { $$ = $1 + $3;}
            | expression '-' multiplication { $$ = $1 - $3;}
            | multiplication { $$ = $1;}
            ;

multiplication:   multiplication '*' term { $$ = $1 * $3;}
                | multiplication '/' term { $$ = $1 / $3;}
                | term { $$ = $1;}
                ;

term: '(' expression ')' { $$ = $2; }
        | NUMBER { $$ = $1; }
        | ID {
            string tmp($1); 
            if(identifiers.count(tmp)==1)  {
            $$=identifiers[tmp];
            cout<<"'"<<tmp<<"' = "<<identifiers[tmp]<<"\n";
            }
            else{
                cout<<"'"<<tmp<<"' not declared!\n";
                $$ = 0;
                }
        }
        ;

branch: IF '(' comparison ')' '{' ID '=' NUMBER '}' ELSE '{' ID '=' NUMBER '}' {
            if($3==1){
                string tmp($6);
                if(identifiers.count(tmp)==1) identifiers[tmp]=$8;
            }
            else {
                string tmp($12);
                if(identifiers.count(tmp)==1) identifiers[tmp]=$14;
            }
        }
    |   IF '(' comparison ')' '{' ID '=' NUMBER '}' { 
            if($3==1){
                string tmp($6);
                if(identifiers.count(tmp)==1) identifiers[tmp] = $8;
            }
        }
    ;

comparison:   num_vs_num { $$=$1 }
            | id_vs_num  { $$=$1 }
            | id_vs_id   { $$=$1 }
            | num_vs_id  { $$=$1 }
            ;

num_vs_num:   NUMBER '>' NUMBER{
                if($1 > $3) {
                    $$=1;
                }
                else { 
                    $$=0;
                }
            }
            | NUMBER '<' NUMBER{
                if($1 < $3) {
                    $$=1;
                }
                else { 
                    $$=0;
                }
            }
            | NUMBER '=' NUMBER {
                if($1 == $3) {
                    $$=1;
                }
                else { 
                    $$=0;
                }
            }
            ;

id_vs_num:    ID '>' NUMBER{
                string tmp($1);
                if(identifiers.count(tmp)==1){
                    if(identifiers[tmp] > $3) $$=1;
                    else $$ = 0;
                }
            }
            | ID '<' NUMBER{
                string tmp($1);
                if(identifiers.count(tmp)==1){
                    if(identifiers[tmp] < $3) $$=1;
                    else $$ = 0;
                }
            }
            | ID '=' NUMBER {
                string tmp($1);
                if(identifiers.count(tmp)==1){
                    if(identifiers[tmp] == $3) $$=1;
                    else $$ = 0;
                }
            }
            ;

num_vs_id:    NUMBER '>' ID{
                string tmp($3);
                if(identifiers.count(tmp)==1){
                    if($1 > identifiers[tmp]) $$=1;
                    else $$ = 0;
                }
            }
            | NUMBER '<' ID{
                string tmp($3);
                if(identifiers.count(tmp)==1){
                    if($1 < identifiers[tmp]) $$=1;
                    else $$ = 0;
                }            
            }
            | NUMBER '=' ID {
                string tmp($3);
                if(identifiers.count(tmp)==1){
                    if($1 = identifiers[tmp]) $$=1;
                    else $$ = 0;
                }            
            }
            ;


id_vs_id:   ID '>' ID{
                string tmp1($1);
                string tmp2($3);
                if(identifiers.count(tmp1)==1 and identifiers.count(tmp2)==1){
                    if(identifiers[tmp1] > identifiers[tmp2]) $$=1;
                    else $$ = 0;
                }
            }
            | ID '<' ID{
                string tmp1($1);
                string tmp2($3);
                if(identifiers.count(tmp1)==1 and identifiers.count(tmp2)==1){
                    if(identifiers[tmp1] < identifiers[tmp2]) $$=1;
                    else $$ = 0;
                }
            }
            | ID '=' ID {
                string tmp1($1);
                string tmp2($3);
                if(identifiers.count(tmp1)==1 and identifiers.count(tmp2)==1){
                    if(identifiers[tmp1] == identifiers[tmp2]) $$=1;
                    else $$ = 0;
                }           
            }
            ;

declare:  TYPE create_val
        | TYPE ID {
            string tmp($2);
            if(identifiers.count(tmp)==1) cout<<"'"<<tmp<<"' already declared!\n";
            else { 
                identifiers[tmp] = 0; 
                cout<<"'"<<tmp<<"' declared!\n";
            }
        }
        ;

setval:   ID '=' NUMBER { 
            string tmp($1);            
            if(identifiers.count(tmp)==1) {
                identifiers[tmp] = $3;
                cout<<"'"<<tmp<<"' = "<<$3<<"\n";
            }
            else { 
                cout<<"'"<<tmp<<"' not declared!\n";
            }
        }
        | ID '=' ID {
            string tmp1($1);
            string tmp2($3);
            if(identifiers.count(tmp1)==1 and identifiers.count(tmp2)==1) {
                identifiers[tmp1] = identifiers[tmp2];
            }
        }
        ;

create_val: ID '=' NUMBER {
                string tmp($1);
                if(identifiers.count(tmp)==0) {
                    identifiers[tmp] = $3;
                    cout<<"'"<<tmp<<"' = "<<$3<<"\n";
                }
                else { 
                    cout<<"'"<<tmp<<"' already declared!\n";
                }
            }
            ;

help: HELP { cout<<"DECLARE:\n"
                "   int|integer 'variable'\n"
                "   int|integer 'variable' = 'value'\n"
                "SET VARIABLE VALUE:\n"
                "   'variable' = 'value'\n"
                "CHECK VARIABLE VALUE:\n"
                "   'variable'\n"
                "CALCULATE:\n"
                "   calc 'expression'\n"
                "BRANCH:\n"
                "   if ('comaprison') {'variable' = 'value'} else {'variable' = 'value'}\n"
                "DELETE VARIABLE:\n"
                "   free 'variable'\n"
                "EXIT:\n"
                "   exit\n"
                }
                ;
%%

int main(){
    if (yyparse() == 0) cout<<"<ACC>\n";
    else cout<<"ERROR\n";
    return 0;
}
