#!/usr/local/gnu/bin/bash

g++ build.cpp -o build -D$SET_PRECISION
./build $INPUT_SOURCE
rm -f *.code
rm -f count
cd ../
