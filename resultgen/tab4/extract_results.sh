#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/tab4

# Output result directory
result_dir=$RESULTS_PATH/fig3

# Setup parameters
declare -a workloadarr=("seqwrite" "seqread")

output="tab4.data"

if [ -f $output ]; then
        rm $output
fi
touch $output
echo "# thread pm_only nvme_only orthus spfs polystore_static polystore_dynamic" > $output
LINE=2

# Extract Results
for i in {0..1}
do
        workload=${workloadarr[i]}
        thread=32

        echo "$workload " >> $output
        
        if [ ! -f $result_dir/pmonly/$workload/$thread/result.txt ]; then
                num=NA
        else
                num="`grep -o 'FAST latency [0-9]*.[0-9]*' $result_dir/pmonly/$workload/$thread/result.txt | sed 's/FAST latency //'1`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output
        
        if [ ! -f $result_dir/nvmeonly/$workload/$thread/result.txt ]; then
                num=NA
        else
                num="`grep -o 'SLOW latency [0-9]*.[0-9]*' $result_dir/nvmeonly/$workload/$thread/result.txt | sed 's/SLOW latency //'1`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output
        
        if [ ! -f $result_dir/orthus/$workload/$thread/result.txt ]; then
                num=NA
        else
                num="`grep -o 'latency [0-9]*.[0-9]*' $result_dir/orthus/$workload/$thread/result.txt | sed 's/latency //'1`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output
        
        if [ ! -f $result_dir/spfs/$workload/$thread/result.txt ]; then
                num=NA
        else
                num="`grep -o 'latency [0-9]*.[0-9]*' $result_dir/spfs/$workload/$thread/result.txt | sed 's/latency //'1`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output
        
        if [ ! -f $result_dir/polystore-static/$workload/$thread/result.txt ]; then 
                num=NA
        else
                num="`grep -o 'latency [0-9]*.[0-9]*' $result_dir/polystore-static/$workload/$thread/result.txt | sed 's/latency //'1`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output

        if [ ! -f $result_dir/polystore-dynamic/$workload/$thread/result.txt ]; then 
                num=NA
        else
                num="`grep -o 'latency [0-9]*.[0-9]*' $result_dir/polystore-dynamic/$workload/$thread/result.txt | sed 's/latency //'1`"
        fi
        sed -i -e "$LINE s/$/ $num/" $output

        let LINE=LINE+1
done
