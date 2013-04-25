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
        private int linesCount = 0;

        public String getDefinition() {
            return definition;
        }

        public String getImplementation() {
            return implementation;
        }

        public int nextArgument() {
            return count++;
        }

        public int getCount() {
            return count;
        }

        private int getLinesCount() {
            return linesCount;
        }

        private int nextLinesCount() {
            return linesCount++;
        }

        private void addFirst(String code, boolean isDefinition) {
            if (isDefinition) {
                definition = code + definition;
            } else {
                implementation = code + implementation;
            }
        }

        private void addLast(String code, boolean isDefinition) {
            if (isDefinition) {
                definition += code;
            } else {
                implementation += code;
            }
        }
    }

    private Map<String, Function> functions = new HashMap<String, Function>();

    private Function current = null;
    private Map<String, Integer> variables = null;
    private int currentArgument = 0;
    private String buffer = null;

    private void addLastToBuffer(String code) {
        buffer += code;
    }

    public String getCode(String fileName) {
        String code = "public class Translated_%s {\n";

        for (Function function : functions.values()) {
            if (function.getLinesCount() != 0) {
                function.addLast(" else {\n\tthrow new IllegalArgumentException();\n}", false);
            }

            String functionCode = "\npublic static " + function.getDefinition() + " {";
            functionCode += function.getImplementation().replaceAll("\n", "\n\t");
            functionCode += "\n}\n";

            code += functionCode.replaceAll("\n", "\n\t");
        }

        code += "\n}\n";
        return String.format(code, fileName);
    }

    private String getTypeName(String type) {
        if (type.equals("Bool")) {
            return "boolean";
        } else {
            return type.toLowerCase();
        }
    }
}

program
    :   NEWLINE* ( function NEWLINE+ )* EOF
    ;

function
    :   definition
    |   mainDefinition
    |   implementation
    |   mainImplementation
    ;

definition
    :   id WS? '::' WS?
        {
            current = functions.get($id.text);
            if (current == null) {
                current = new Function();
            }

            current.addLast($id.text + "(", true);
        }
        (
            Type
            {
                if (current.getCount() > 0) {
                    current.addLast(", ", true);
                }
                current.addLast(getTypeName($Type.text) + " arg" + current.nextArgument(), true);
            }
            WS? '->' WS? )*
        Type WS?
        {
            current.addLast(")", true);
            current.addFirst(getTypeName($Type.text) + " ", true);

            functions.put($id.text, current);
            current = null;
        }
    ;

mainDefinition
    :   'main' WS? '::' WS? 'IO()'
         {
             current = functions.get("main");
             if (current == null) {
                 current = new Function();
             }

             current.addLast("void main(String[] args)", true);

             functions.put("main", current);
             current = null;
         }
    ;

implementation
    @init {
        boolean isFirstArgument = true;
    }
    :   id
        {
            current = functions.get($id.text);
            if (current == null) {
                current = new Function();
            }

            buffer = "";
        }
        (
            WS
            {
                if (!isFirstArgument) {
                     buffer += " && ";
                } else {
                    isFirstArgument = false;
                }
                buffer += "(";
            }
            argument
            {
                buffer  += ")";
                currentArgument++;
            }
        )* WS? (
            '|' WS?
            {
                if (!isFirstArgument) {
                    buffer += " && ";
                } else {
                    isFirstArgument = false;
                }
                buffer += "(";
            }
            booleanExpression WS?
            {
                buffer += ")";
            }
        )?
        '=' WS?
        {
            if (!buffer.equals("")) {
                if (current.getLinesCount() != 0) {
                    current.addLast(" else ", false);
                } else {
                    current.addLast("\n", false);
                    current.nextLinesCount();
                }
                current.addLast("if (" + buffer + ") {", false);

                buffer = "";
            }
        }
        expression
        {
            current.addLast("\n", false);
            if (currentArgument != 0) {
                current.addLast("\t", false);
            }
            current.addLast("return " + buffer + ";", false);
            if (currentArgument != 0) {
                current.addLast("\n}", false);
            }

            functions.put($id.text, current);
            buffer = null;
            currentArgument = 0;
        }
    ;

mainImplementation
    :   'main' WS? '=' WS? 'print' WS expression
    ;

Type
    :   'Int'
    |   'Bool'
    ;

argument
    :   expression
    {
        addLastToBuffer(" == arg" + currentArgument);
    }
    |   id
    {
        variables.put($id.text, currentArgument++);
    }
    |   UnderLine
    {
        addLastToBuffer("true");
    }
    ;

call
   :    id WS? ( expression WS )*
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

expression
    :   booleanExpression
    |   arithmeticExpression
    ;

booleanExpression
    :   ( booleanMonomial WS? booleanExpressionSuffix )
    ;

booleanMonomial
    :   booleanValue
    |   ( BoolUnaryOperator WS booleanMonomial )
    ;

booleanExpressionSuffix
    :   WS?
    |   ( boolBinaryOperator WS? booleanMonomial WS? booleanExpressionSuffix)
    ;

booleanValue
    :   Bool
    |   call
    |   ( LEFT_PARENTHESIS WS? booleanExpression WS? RIGHT_PARENTHESIS )
    ;


boolBinaryOperator
    :   '&&'
    |   '||'
    |   EqOperator
    ;

BoolUnaryOperator
    :   'not'
    ;


Bool
    :   'True'
    |   'False'
    ;

arithmeticExpression
    :   integral
    |   id
    |   call
    |   ( LEFT_PARENTHESIS WS? arithmeticExpression WS? RIGHT_PARENTHESIS )
    |   ( arithmeticExpression WS? ArithmeticBinaryOperator WS? arithmeticExpression )
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

LowerCase
    :   'a' .. 'z'
    ;

UpperCase
    :   'A' .. 'Z'
    ;

UnderLine
    :   '_'
    ;

Apostrophe
    :   '\''
    ;

id
    :   (
        (
            LowerCase
        |   UpperCase
        ) idSuffix?
    )
    | (
        UnderLine idSuffix
    )
    ;

idSuffix
    :   (
            LowerCase
        |   UpperCase
        |   Digit
        |   Apostrophe
    )+
    | (
        UnderLine idSuffix?
    )
    ;


Digit
    :   '0' .. '9'
    ;

Sign
    :   '+'
    |   '-'
    ;

integral
    :   Sign? Digit+
    ;
