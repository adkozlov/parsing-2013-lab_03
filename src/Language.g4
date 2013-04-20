grammar Language;

@members {
    private String code = new String();

    private String buffer;
    private int current;

    public String getCode() {
        return code;
    }

    private void startBuffer() {
        buffer = new String();
        current = 0;
    }

    private void addFirst(String code) {
        buffer = code + buffer;
    }

    private void addLast(String code) {
        buffer += code;
    }

    private void finishBuffer() {
        code += buffer;
        buffer = null;
    }

    private int nextArgument() {
        return current++;
    }

    private int getArgumentCount() {
        return current;
    }
}

s
    :   GAP? ( function GAP )+
        {
            startBuffer();
            addLast("int main(int argc, char *argv[])\n{\n\treturn 0;\n}");
            finishBuffer();
        }
    ;

function
    :   {
            startBuffer();
        }
        definition
        {
            addLast("\n{\n");
        }
        ( NEWLINE implementation )+
        {
            addLast("}\n\n");
            finishBuffer();
        }
    ;

definition
    :   id
        {
            addLast($id.text.toLowerCase() + "(");
        }
        WS '::'  WS (
        type
        {
            if (getArgumentCount() > 0) {
                addLast(", ");
            }
            addLast($type.text.toLowerCase() + " arg" + nextArgument());
        }
        WS '->' WS )*
        type
        {
            addFirst($type.text.toLowerCase() + " ");
            addLast(")");
        }
    ;

implementation
    :   id WS ( ( value | id ) WS )* '=' WS value
    ;

WS
    :   (
            ' '
        |   '\t'
        )+
    ;

NEWLINE
    :   '\n'
    ;

GAP
    :   NEWLINE+
    ;

type
    :   'Int'
    |   'Double'
    |   'Bool'
    |   'Char'
    ;

LowerCase
    :   'a' .. 'z'
    ;

UpperCase
    :   'A' .. 'Z'
    ;

UnderLine
    :   '_'
    ;

id
    :   (
            LowerCase
        |   UpperCase
        |   UnderLine
        ) (
            LowerCase
        |   UpperCase
        |   DecDigit
        |   UnderLine
        )*
    ;

DecDigit
    :   '0' .. '9'
    ;

OctDigit
    :   '0' .. '7'
    ;

OctPrefix
    :   '0'
            'o'
        |   'O'
    ;

HexDigit
    :   DecDigit
    |   'a' .. 'f'
    |   'A' .. 'F'
    ;

HexPrefix
    :   '0'
            'x'
        |   'X'
    ;

Sign
    :   '+'
    |   '-'
    ;

value
    :   integral
    |   bool
    ;

integral
    :   Sign?
            DecDigit+
        |   OctPrefix OctDigit+
        |   HexPrefix HexDigit+
    ;

bool
    :   'True'
    |   'False'
    ;