#!/bin/bash

cd tests
ls | grep -v 'java\|hs$' | xargs rm
cd ..
