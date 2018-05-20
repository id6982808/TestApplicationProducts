#!/usr/local/gnu/bin/bash

g++ filter.cpp -o filter
./filter ../$SOURCE_FILE
mv ../*.kernel ../input_source/
