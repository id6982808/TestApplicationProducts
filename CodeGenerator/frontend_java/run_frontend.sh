#!/usr/local/gnu/bin/bash

#javac lexer/*.java
#javac symbols/*.java
#javac inter/*.java
#javac parser/*.java
#javac main/*.java

java main.Main < ../input_source/$SRC > ../middle_cpp/$SRC.code
rm -f ../input_source/$SRC
