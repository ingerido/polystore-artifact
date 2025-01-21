#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig9a

# Output result directory
result_dir=$RESULTS_PATH/fig9a

# Extract Results
output="fig9a.data"

if [ -f $output ]; then
        rm $output
fi
touch $output
echo "# orthus spfs polystore" > $output
LINE=2

echo "Run time: " >> $output

if [ ! -f $result_dir/orthus/result.txt ]; then
        num=NA
else
        num="`grep "00_runtime:" $result_dir/orthus/result.txt | awk '{print $2}'`"
fi
sed -i -e "$LINE s/$/ $num/" $output

if [ ! -f $result_dir/spfs/result.txt ]; then
        num=NA
else
        num="`grep "00_runtime:" $result_dir/spfs/result.txt | awk '{print $2}'`"
fi
sed -i -e "$LINE s/$/ $num/" $output

if [ ! -f $result_dir/polystore/result.txt ]; then
        num=NA
else               
        num="`grep "00_runtime:" $result_dir/polystore/result.txt | awk '{print $2}'`"
fi
sed -i -e "$LINE s/$/ $num/" $output

let LINE=LINE+1
