
%{
    #include "grammar.tab.h"
    #include <cstring>
    #include <iostream>
    using namespace std;
%}

%option noyywrap

DIGITS          [0-9]
ALPHABET        [a-zA-Z]
CHARACTERTOKENS [\+\-\*\/\(\)\{\}] 
COMPARATIVE     [\<\>\=]

%%
exit                                return '\0';
int|integer                         return TYPE;
if                                  return IF;
help                                return HELP; 
else                                return ELSE;
free                                return FREE;
calc                                return CALC;
{CHARACTERTOKENS}|{COMPARATIVE}     return *yytext;
0|[1-9]{DIGITS}*                    yylval.value=atoi(yytext); return NUMBER;
{ALPHABET}*                         strcpy(yylval.name,yytext); return ID;
\n                                  return '\n';
[ \t]                               /* skip whitespace */
%%