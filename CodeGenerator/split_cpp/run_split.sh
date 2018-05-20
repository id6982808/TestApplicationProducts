#!/usr/local/gnu/bin/bash
g++ split.cpp -o split -D$SET_PRECISION
./split ../input_source/$INPUT_SOURCE
rm -f fixed.temp
