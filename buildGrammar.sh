#!/bin/sh

rm -f src/Language?*.*
java -jar lib/antlr-4.0-complete.jar src/Language.g4
