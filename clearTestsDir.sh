#!/bin/bash

cd tests
ls | grep -v 'c\|hs$' | xargs rm
cd ..
