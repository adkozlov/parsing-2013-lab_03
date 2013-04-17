import org.antlr.v4.runtime.*;

import java.io.*;

public class Tester {

    private static final int TESTS_COUNT = 10;
    private static final String TESTS_PATH = "tests/";
    private static final String TESTS_FORMAT = "%02d";
    private static final String TESTS_IN_EXTENSION = ".in";
    private static final String TESTS_OUT_EXTENSION = ".out";

    private static final String SUCCESS_MESSAGE = TESTS_FORMAT + " success\n";
    private static final String ERROR_MESSAGE = TESTS_FORMAT + " failed: %s\n";

    private static String testFileName(int index, boolean isIn) {
        return TESTS_PATH + String.format(TESTS_FORMAT, index) + (isIn ? TESTS_IN_EXTENSION : TESTS_OUT_EXTENSION);
    }

    public static void main(String[] args) {
        for (int i = 0; i < TESTS_COUNT; i++) {
            try {
                CharStream input = new ANTLRInputStream(new FileInputStream(testFileName(i, true)));
                LanguageLexer lexer = new LanguageLexer(input);

                LanguageParser parser = new LanguageParser(new CommonTokenStream(lexer));
                // TODO parser.root();

                PrintWriter pw = new PrintWriter(testFileName(i, false));
                pw.println(); // TODO parser.getCode();
                pw.close();

                System.out.printf(SUCCESS_MESSAGE, i);
            } catch (IOException e) {
                System.out.printf(ERROR_MESSAGE, i, e.getLocalizedMessage());
            }
        }
    }
}
