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
        private boolean needsThrow = true;

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

        private void nextLine() {
            linesCount++;
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

    public String getCode(String mask, String fileName) {
        String code = String.format("public class %s%s {\n", mask, fileName);

        for (Function function : functions.values()) {
            if (function.needsThrow) {
                function.addLast(" else {\n\tthrow new IllegalArgumentException();\n}", false);
            }

            String functionCode = "\npublic static " + function.getDefinition() + " {";
            functionCode += function.getImplementation().replaceAll("\n", "\n\t");
            functionCode += "\n}\n";

            code += functionCode.replaceAll("\n", "\n\t");
        }

        code += "\n}\n";
        return code;
    }

    private String getTypeName(String type) {
        if (type.equals("Bool")) {
            return "boolean";
        } else {
            return type.toLowerCase();
        }
    }

    private Function start(String name) {
        Function result = functions.get(name);
        if (result == null) {
            result = new Function();
        }
        currentArgument = 0;
        buffer = "";

        return result;
    }

    private void finish(String name, Function function) {
        functions.put(name, function);
        function = null;
        currentArgument = 0;
        buffer = null;
    }
}

program
    :   NEWLINE* ( function WS? comment? NEWLINE+ )* EOF
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
            current = start($id.text);
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

            finish($id.text, current);
        }
    ;

mainDefinition
    :   'main' WS? '::' WS? 'IO()'
         {
            current = start("main");
            current.addLast("void main(String[] args)", true);
            finish("main", current);
         }
    ;

implementation
    @init {
        boolean isFirstArgument = true;
        String arguments = "";
    }
    :   id
        {
            current = start($id.text);
            variables = new HashMap<String, Integer>();
        }
        (
            WS argument
            {
                if (!buffer.equals("")) {
                    if (!isFirstArgument) {
                        arguments += " && ";
                    } else {
                    isFirstArgument = false;
                    }

                    arguments += buffer;

                }

                currentArgument++;
                buffer = "";
            }
        )* WS? (
            '|' WS? booleanExpression WS?
            {
                if (!isFirstArgument) {
                    arguments += " && ";
                } else {
                    isFirstArgument = false;
                }

                arguments += buffer;
                buffer = "";
            }
        )?
        '=' WS?
        {
            if (current.getLinesCount() != 0) {
                current.addLast(" else ", false);
            } else {
                current.addLast("\n", false);
            }

            if (!arguments.equals("")) {
                current.addLast("if (" + arguments + ") ", false);
            } else {
                current.needsThrow = false;
            }

            if (current.getLinesCount() != 0 || !arguments.equals("")) {
                current.addLast("{", false);
            }
        }
        arithmeticExpression
        {
            if (current.getLinesCount() != 0 || !arguments.equals("")) {
                current.addLast("\n\t", false);
            }
            current.addLast("return " + buffer + ";", false);
            if (current.getLinesCount() != 0 || !arguments.equals("")) {
                current.addLast("\n}", false);
            }

            current.nextLine();

            finish($id.text, current);
            variables = null;
        }
    ;

mainImplementation
    :   'main' WS? '=' WS? 'print' WS
    {
        current = start("main");
        current.needsThrow = false;
    }
    arithmeticExpression
    {
        current.addLast("\nSystem.out.println(" + buffer + ");", false);
        finish("main", current);
    }
    ;

comment
    :   CommentLinePrefix ( ~NEWLINE )*
    ;

CommentLinePrefix
    :   '--'
    ;

Type
    :   'Int'
    |   'Double'
    |   'Bool'
    ;

argument
    :   (
            number
            {
                addLastToBuffer($number.text + " == arg" + currentArgument);
            }
    ) | (
            id
            {
                variables.put($id.text, currentArgument);
            }
    ) | (
            UnderLine
    )
    ;

call
    :   LEFT_PARENTHESIS WS? id
        {
            addLastToBuffer($id.text + "(");
        }
        WS? (
            arithmeticExpression WS
            {
                addLastToBuffer(", ");
            }
        )*
        arithmeticExpression? WS?
        RIGHT_PARENTHESIS
        {
            addLastToBuffer(")");
        }
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
    :   booleanMonomial WS? booleanExpressionSuffix
    ;

booleanMonomial
    :   booleanValue
    |   (
            BoolUnaryOperator
            {
                addLastToBuffer("!");
            }
            WS booleanMonomial
        )
    ;

booleanExpressionSuffix
    :   WS?
    |   (
            boolBinaryOperator
            {
                addLastToBuffer(" " + $boolBinaryOperator.text + " ");
            }
            WS? booleanMonomial WS? booleanExpressionSuffix
        )
    ;

booleanValue
    :   (
            Bool
            {
                addLastToBuffer($Bool.text);
            }
    ) | (
            id
            {
                addLastToBuffer("arg" + variables.get($id.text));
            }
    ) | (
            arithmeticExpression WS?
            ordOperator
            {
                addLastToBuffer(" " + ($ordOperator.text.equals("/=") ? "!=" : $ordOperator.text) + " ");
            }
            WS? arithmeticExpression
    ) | (
            LEFT_PARENTHESIS WS?
            {
                addLastToBuffer("(");
            }
            booleanExpression WS?
            (
                EqOperator
                {
                    addLastToBuffer(" " + ($EqOperator.text.equals("/=") ? "!=" : $EqOperator.text) + " ");
                }
                WS? booleanExpression WS?
            )?
            RIGHT_PARENTHESIS
            {
                addLastToBuffer(")");
            }
        )
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
    :   arithmeticValue WS? arithmeticExpressionSuffix
    ;

arithmeticExpressionSuffix
    :   WS?
    |   (
            ArithmeticBinaryOperator WS?
            {
                addLastToBuffer(" " + ($ArithmeticBinaryOperator.text.equals("`div`") ? "/" : ($ArithmeticBinaryOperator.text.equals("`mod`") ? "%" : $ArithmeticBinaryOperator.text)) + " ");
            }
            arithmeticValue WS? arithmeticExpressionSuffix
    )
    ;

arithmeticValue
    :   (
            number
            {
                addLastToBuffer($number.text);
            }
    ) | (
            id
            {
                addLastToBuffer("arg" + variables.get($id.text));
            }
    ) | (
            call
    ) | (
            LEFT_PARENTHESIS WS?
            {
                addLastToBuffer("(");
            }
            arithmeticExpression WS? RIGHT_PARENTHESIS
            {
                addLastToBuffer(")");
            }
    )
    ;

ArithmeticBinaryOperator
    :   '+'
    |   '-'
    |   '*'
    |   '/'
    |   '`div`'
    |   '`mod`'
    ;
number
    :   integral
    |   fractional
    ;

integral
    :   Sign? Digit+
    ;

fractional
    :   Digit+ Point Digit* Exponent?
    |   Point Digit+ Exponent?
    |   Digit+ Exponent
    |   Digit+
    ;

Exponent
    :   (
            'e'
        |   'E'
        )
        Sign?
        Digit+
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

Point
    :   '.'
    ;
