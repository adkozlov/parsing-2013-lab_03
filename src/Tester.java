import org.antlr.v4.runtime.*;

import java.io.*;

public class Tester {

    private static final String TESTS_PATH = "tests/";
    private static final String TESTS_FORMAT = "%s";
    private static final String TESTS_IN_EXTENSION = ".hs";
    private static final String TESTS_OUT_EXTENSION = ".java";

    private static final String START_MESSAGE = TESTS_FORMAT + " started\n";
    private static final String SUCCESS_MESSAGE = TESTS_FORMAT + " succeeded\n";
    private static final String FAIL_MESSAGE = TESTS_FORMAT + " failed: %s\n";

    public static void main(String[] args) {
        File dir  = new File(TESTS_PATH);
        dir.mkdir();

        for (String fileName : dir.list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.endsWith(TESTS_IN_EXTENSION);
            }
        })) {
            //System.out.printf(START_MESSAGE, fileName);
            String testName = fileName.replace(TESTS_IN_EXTENSION, "");

            try {
                CharStream input = new ANTLRInputStream(new FileInputStream(TESTS_PATH + testName + TESTS_IN_EXTENSION));
                LanguageLexer lexer = new LanguageLexer(input);

                LanguageParser parser = new LanguageParser(new CommonTokenStream(lexer));
                parser.program();

                PrintWriter pw = new PrintWriter(TESTS_PATH + testName + TESTS_OUT_EXTENSION);
                pw.println(parser.getCode(testName));
                pw.close();

                //System.out.printf(SUCCESS_MESSAGE, fileName);
            } catch (Exception e) {
                //System.out.printf(FAIL_MESSAGE, fileName, e.getMessage());
            }
        }
    }
}
