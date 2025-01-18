#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig8a

# Output result directory
result_dir=$RESULTS_PATH/fig8a

# Setup parameters
declare -a workloadarr=("ycsbwklda" "ycsbwkldb" "ycsbwkldc" "ycsbwkldd" "ycsbwklde" "ycsbwkldf")

# Extract Results
output="fig8a.data"

if [ -f $output ]; then
        rm $output
fi
touch $output
echo "# workload pm_only nvme_only orthus spfs polystore" > $output
LINE=2

for i in {0..5}
do
        workload=${workloadarr[i]}
        echo "$workload " >> $output
        
        if [ ! -f $result_dir/pmonly/$workload/result.txt ]; then
                num=NA
        else
                num="`awk '/ycsbwkld/ {print}' $result_dir/pmonly/$workload/result.txt | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output

        if [ ! -f $result_dir/nvmeonly/$workload/result.txt ]; then
                num=NA
        else
                num="`awk '/ycsbwkld/ {print}' $result_dir/nvmeonly/$workload/result.txt | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output
        
        if [ ! -f $result_dir/orthus/$workload/result.txt ]; then
                num=NA
        else
                num="`awk '/ycsbwkld/ {print}' $result_dir/orthus/$workload/result.txt | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output

        if [ ! -f $result_dir/spfs/$workload/result.txt ]; then
                num=NA
        else
                num="`awk '/ycsbwkld/ {print}' $result_dir/spfs/$workload/result.txt | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output

        if [ ! -f $result_dir/polystore/$workload/result.txt ]; then
                num=NA
        else               
                num="`awk '/ycsbwkld/ {print}' $result_dir/polystore/$workload/result.txt | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output

        let LINE=LINE+1
done
