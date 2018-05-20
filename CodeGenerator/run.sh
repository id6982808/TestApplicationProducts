#!/usr/local/gnu/bin/bash

# please set source file in this directory and input name in a below variable
export SOURCE_FILE=$1
# please set precision you want to use [D, DD, TD, QD]
export SET_PRECISION=$2
# ::example::
#export SOURCE_FILE='sample.q'
#export SET_PRECISION='D'


par_path=`dirname $0`
cd $par_path


mkdir ./input_source/
cd ./filter/
./run_filter.sh
export INPUT_SOURCE=$SOURCE_FILE'.kernel'
cd ../

cd ./split_cpp/
./run_split.sh
cd ../
cd ./input_source/
count_src_file=`find ./ -name "*.src" | wc -l`
cd ../
echo $count_src_file > ./final_codes/count

n=0
PRENAME='calc'
POSTNAME='.src'
while [ $n -lt $count_src_file ]
do

export SRC=$PRENAME$n$POSTNAME
cd ./frontend_java/
./run_frontend.sh
cd ../
cd ./middle_cpp/
./run_middle.sh
cd ../

n=$(($n + 1))
done

mv ./middle_cpp/*.code ./final_codes
mv ./split_cpp/*.code ./final_codes

cd ./final_codes/
./run_build.sh
mv *.cl ../
cd ../
rm -rf ./input_source/
