#!/bin/bash

cd tests

for file in `ls | grep -e ".hs"`; do
    filename="${file%.*}"

    ghc ${file}
    echo "haskell out:"
    ./${filename}
    echo "java out:"

    javafile="Translated_"${filename}".java"
    javac $javafile
    java "Translated_"${filename%.*}

    ls | grep -v 'java\|hs$' | xargs rm
done

cd ..
