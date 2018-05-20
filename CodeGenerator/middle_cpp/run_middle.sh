#!/usr/local/gnu/bin/bash

g++ conv_front.cpp -o conv_front
g++ conv_modified.cpp -o conv_modified
g++ conv_term3.cpp -o conv_term3 -D$SET_PRECISION
./conv_front $SRC.code
./conv_modified >> temp_counter.code
./conv_term3 $SRC
rm -f $SRC.code
rm -f modified.code
rm -f term3.code
