grammar Language;

prog
    :   (expr NEWLINE)* ;
expr
    :	expr ('*'|'/') expr
    |	expr ('+'|'-') expr
    |	INT
    |	'(' expr ')' ;

INT
	:	Integral
	;

fragment
Integral
    :   DecDigit+
    |   OctPrefix OctDigit+
    |   HexPrefix HexDigit+
    ;

fragment
DecDigit
    :   '0' .. '9'
    ;

fragment
OctPrefix
    :   '0o'
    |   '0O'
    ;

fragment
OctDigit
    :   '0' .. '7'
    ;

fragment
HexDigit
    :   '0' .. '9'
    |   'a' .. 'f'
    |   'A' .. 'F'
    ;

fragment
HexPrefix
    :   '0x'
    |   '0X'
    ;

FLOAT
    :   Fractional FloatSuffix
    ;

DOUBLE
    :   Fractional DoubleSuffix?
    ;

fragment
FloatSuffix
    :   'f'
    |   'F'
    ;

fragment
DoubleSuffix
    :   'd'
    |   'D'
    ;

fragment
Fractional
    :   (DecDigit+)? '.' DecDigit* Exponent?
    |   DecDigit+ Exponent?
    ;

fragment
Exponent
    :   ExponentPrefix Sign? DecDigit+
    ;

fragment
ExponentPrefix
    :   'e'
    |   'E'
    ;

fragment
Sign
    :   '+'
    |   '-'
    ;

CHAR
    :   '\'' (
            EscapeSequence
        |   ~( '\'' | '\\' | '\r' | '\n' )
        ) '\''
    ;

fragment
EscapeSequence
    :   '\\' (
            'b'
        |   't'
        |   'n'
        |   'f'
        |   'r'
        |   '\"'
        |   '\''
        |   '\\'
        |   OctDigit OctDigit OctDigit
        |   OctDigit OctDigit
        |   OctDigit
        )
    ;

fragment
LowerCase
    :   'a' .. 'z'
    ;

fragment
UpperCase
    :   'A' .. 'Z'
    ;

BOOL
    :   'True'
    |   'False'
    ;