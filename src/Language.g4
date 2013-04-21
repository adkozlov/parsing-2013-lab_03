grammar Language;

@members {
    private String code = "#include <iostream>\n\n";
    private int codeOffset = 0;

    public String makeOffset() {
        String result = "";
        for (int i = 0; i < codeOffset; i++) {
            result += "\t";
        }
        return result;
    }

    public String getCode() {
        return code + "int main(int argc, char *argv[])\n{\n\treturn 0;\n}\n";
    }

    private void addFirst(String code) {
        if (buffer == null) {
            this.code = code + this.code;
        } else {
            buffer = code + buffer;
        }
    }

    private void addLast(String code) {
        if (buffer == null) {
            this.code += code;
        } else {
            buffer += code;
        }
    }

    private String buffer = null;

    private void startBuffer() {
        buffer = new String();
    }

    private void finishBuffer() {
        code += buffer;
        buffer = null;
        currentArgument = 0;
    }

    private int currentArgument = 0;

    private int nextArgument() {
        return currentArgument++;
    }

    private int getArgumentCount() {
        return currentArgument;
    }
}

program
    :   NEWLINE* (
                    (
                        function
                    |   commentBlock
                    |   commentLine
                    )
                    NEWLINE+
                    {
                        addLast("\n\n");
                    }
                )* EOF
    ;

function
    :   {
            startBuffer();
        }
        definition
        {
            addLast("\n{\n");
        }
        ( NEWLINE+ implementation )+
        {
            addLast("}");
            finishBuffer();
        }
    ;

definition
    :   id WS '::' WS
        {
            addLast($id.text + "(");
        }
        (
            Type
            {
                if (getArgumentCount() > 0) {
                    addLast(", ");
                }
                addLast($Type.text.toLowerCase() + " arg" + nextArgument());
            }
            WS '->' WS )*
        Type
        {
            addFirst($Type.text.toLowerCase() + " ");
            addLast(")");
        }
        commentLine?
    ;

implementation
    :   id WS ( ( value | id ) WS )* '=' WS value
    ;

commentBlock
    :   '{-' '|'? multiLineCommentText '-}'
        {
            addLast("/*" + $multiLineCommentText.text + "*/");
        }
    ;

multiLineCommentText
    :   ~'-}'*
    ;

commentLine
    :   '--' commentText
        {
            addLast("//" + $commentText.text);
        }
    ;

commentText
    :   ~NEWLINE*
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

Type
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