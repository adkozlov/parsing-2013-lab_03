grammar Language;

prog
    :   (expr NEWLINE)* ;
expr
    :	expr ('*'|'/') expr
    |	expr ('+'|'-') expr
    |	INT
    |	'(' expr ')' ;