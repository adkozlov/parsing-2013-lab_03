grammar Language;

@header {
    import java.util.Map;
    import java.util.HashMap;
}

@members {
    private class Function {
        private String definition = "";
        private String implementation = "";
        private int count = 0;
    }

    private Map<String, Function> functions = new HashMap<String, Function>();
    private Function current;

    public String getCode(String fileName) {
        String code = "public class Translated_%s {\n";

        for (Function function : functions.values()) {
            String functionCode = "\n\tpublic static " + function.definition + " {\n";
            functionCode += function.implementation;
            functionCode += "\t}\n";

            code += functionCode;
        }

        code += "\n}\n";
        return String.format(code, fileName);
    }

    private void addFirst(String code, boolean isDefinition) {
        if (isDefinition) {
            current.definition = code + current.definition;
        } else {
            current.implementation = code + current.implementation;
        }
    }

    private void addLast(String code, boolean isDefinition) {
        if (isDefinition) {
            current.definition += code;
        } else {
            current.implementation += code;
        }
    }

    private int nextArgument() {
        return current.count++;
    }

    private int getArgumentCount() {
        return current.count;
    }

    private String getTypeName(String type) {
        if (type.equals("Int")) {
            return "int";
        } else if (type.equals("Double")) {
            return "double";
        } else if (type.equals("Bool")) {
            return "boolean";
        } else if (type.equals("IO()")) {
            return "void";
        } else {
            throw new IllegalArgumentException("unknown type");
        }
    }
}

program
    :   NEWLINE* ( function NEWLINE+ )* EOF
    ;

function
    :   definition
    |   implementation
    ;

definition
    @init {
        boolean isMain = false;
    }
    :   id WS '::' WS
        {
            current = functions.get($id.text);
            if (current == null) {
                current = new Function();
            }
            addLast($id.text + "(", true);

            if ($id.text.equals("main")) {
                isMain = true;
            }
        }
        (
            Type
            {
                if (getArgumentCount() > 0) {
                    addLast(", ", true);
                }
                addLast(getTypeName($Type.text) + " arg" + nextArgument(), true);
            }
            WS '->' WS )*
        Type WS?
        {
            if (isMain) {
                addLast("String[] args", true);
            }
            addLast(")", true);
            addFirst(getTypeName($Type.text) + " ", true);

            functions.put($id.text, current);
            current = null;
        }
    ;

implementation
    :   id ( WS argument )* WS? ( '|' booleanExpression WS? )? '=' WS value
    ;

argument
    :   value
    |   id
    |   UnderLine
    ;

LEFT_PARENTHESIS
    :   '('
    ;

RIGHT_PARENTHESIS
    :   ')'
    ;

EqOperator
    :   '=='
    |   '/='
    ;

ordOperator
    :   EqOperator
    |   '<'
    |   '<='
    |   '>'
    |   '>='
    ;

booleanExpression
    :   id
    |   Bool
    |   LEFT_PARENTHESIS booleanExpression RIGHT_PARENTHESIS
    |   booleanExpression WS? boolBinaryOperator WS? booleanExpression
    |   BoolUnaryOperator WS booleanExpression
    |   arithmeticExpression WS? ordOperator WS? arithmeticExpression
    ;

boolBinaryOperator
    :   '&&'
    |   '||'
    |   EqOperator
    ;

BoolUnaryOperator
    :   'not'
    ;

arithmeticExpression
    :   id
    |   number
    |   LEFT_PARENTHESIS arithmeticExpression RIGHT_PARENTHESIS
    |   arithmeticExpression WS? ArithmeticBinaryOperator WS? arithmeticExpression
    ;

ArithmeticBinaryOperator
    :   '+'
    |   '-'
    |   '*'
    |   '/'
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
    |   'IO()'
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
        |   Digit
        |   UnderLine
        )*
    ;

Digit
    :   '0' .. '9'
    ;

Sign
    :   '+'
    |   '-'
    ;

value
    :   number
    |   Bool
    ;

number
    :   integral
    |   fractional
    ;

integral
    :   Sign? Digit+
    ;

fractional
    :
    ;

Bool
    :   'True'
    |   'False'
    ;