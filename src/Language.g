grammar Language;

prog
    :   (expr NEWLINE)* ;
expr
    :	expr ('*'|'/') expr
    |	expr ('+'|'-') expr
    |	INT
    |	'(' expr ')' ;

protected
INTEGER
	:	IntegerNumber
	;

protected
LONG
    :   IntegerNumber LongSuffix
    ;

fragment
LongSuffix
    :   'l'
    |   'L'
    ;

fragment
IntegerNumber
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

protected
FLOAT
    :   RealNumber FloatSuffix
    ;

protected
DOUBLE
    :   RealNumber DoubleSuffix?
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
RealNumber
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

// TODO char

fragment
LowerCase
    :   'a' .. 'z'
    ;

fragment
UpperCase
    :   'A' .. 'Z'
    ;
