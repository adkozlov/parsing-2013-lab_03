grammar Language;

@header {
    import java.util.Map;
    import java.util.HashMap;
}

@members {
    protected class Function {
        private String definition = "";
        private String implementation = "";
        private int count = 0;
        private boolean isFirstLine = true;

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

        private boolean isFirst() {
            return isFirstLine;
        }

        private void changeIsFirst() {
            isFirstLine = false;
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
            String functionCode = "\n\tpublic static " + function.getDefinition() + " {\n";
            functionCode += function.getImplementation().replace("\t", "\t\t");
            functionCode += "\t}\n";

            code += functionCode;
        }

        code += "\n}\n";
        return String.format(code, fileName);
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
            current.addLast($id.text + "(", true);

            if ($id.text.equals("main")) {
                isMain = true;
            }
        }
        (
            Type
            {
                if (current.getCount() > 0) {
                    current.addLast(", ", true);
                }
                current.addLast(getTypeName($Type.text) + " arg" + current.nextArgument(), true);
            }
            WS '->' WS )*
        Type WS?
        {
            if (isMain) {
                current.addLast("String[] args", true);
            }
            current.addLast(")", true);
            current.addFirst(getTypeName($Type.text) + " ", true);

            functions.put($id.text, current);
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
            '|'
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
                if (!current.isFirst()) {
                    current.addLast(" else ", false);
                } else {
                    current.addLast("\t", false);
                    current.changeIsFirst();
                }
                current.addLast("if (" + buffer + ") {\n", false);

                buffer = "";
            }
        }
        expression
        {
            current.addLast("\treturn " + buffer + ";\n}", false);

            functions.put($id.text, current);
            buffer = null;
            currentArgument = 0;
        }
    ;

argument
    :   value
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
   :    id
        {
            System.out.println($id.text);
        }
   ( WS ( value | id | call ))
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
    :   id
    |   Bool
    |   call
    |   LEFT_PARENTHESIS WS? booleanExpression WS? RIGHT_PARENTHESIS
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
    |   call
    |   LEFT_PARENTHESIS WS? arithmeticExpression WS? RIGHT_PARENTHESIS
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
    |   arithmeticExpression
    |   Bool
    |   booleanExpression
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