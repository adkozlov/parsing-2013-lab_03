import org.antlr.v4.runtime.*;

import java.io.*;
import java.util.Arrays;

public class Tester {

    private static final int TESTS_COUNT = 10;
    private static final String TESTS_PATH = "tests/";
    private static final String TESTS_FORMAT = "%02d";
    private static final String TESTS_IN_EXTENSION = ".hs";
    private static final String TESTS_OUT_EXTENSION = ".c";

    private static final String START_MESSAGE = TESTS_FORMAT + " started\n";
    private static final String SUCCESS_MESSAGE = TESTS_FORMAT + " succeeded\n";
    private static final String FAIL_MESSAGE = TESTS_FORMAT + " failed: %s\n";

    private static String testFileName(int index, boolean isIn) {
        return TESTS_PATH + String.format(TESTS_FORMAT, index) + (isIn ? TESTS_IN_EXTENSION : TESTS_OUT_EXTENSION);
    }

    public static void main(String[] args) {
        for (int i = 0; i < TESTS_COUNT; i++) {
            //System.out.printf(START_MESSAGE, i);

            try {
                CharStream input = new ANTLRInputStream(new FileInputStream(testFileName(i, true)));
                LanguageLexer lexer = new LanguageLexer(input);

                LanguageParser parser = new LanguageParser(new CommonTokenStream(lexer));
                parser.s();

                PrintWriter pw = new PrintWriter(testFileName(i, false));
                pw.println(parser.getCode());
                pw.close();

                //System.out.printf(SUCCESS_MESSAGE, i);
            } catch (Exception e) {
                //System.out.printf(FAIL_MESSAGE, i, e.getLocalizedMessage());
            }
        }
    }
}
