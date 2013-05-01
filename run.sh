#!/bin/bash

cd tests

for haskellfile in `ls | grep -e ".hs"`; do
    filename=${haskellfile%.*}

    ghc ${haskellfile}
    echo "haskell out:"
    ./${filename}
    echo "java out:"

    javafile="Translated_"${filename}".java"
    javac $javafile
    java ${javafile%.*}

    ls | grep -v 'java\|hs$' | xargs rm
done

cd ..
