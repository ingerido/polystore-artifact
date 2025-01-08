#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig3

# Output result directory
result_dir=$RESULTS_PATH/fig3

# Setup parameters
declare -a threadarr=("2" "4" "8" "16" "32")
declare -a workloadarr=("seqwrite" "randread" "randwrite" "seqread")
declare -a figurearr=("fig3a" "fig3d" "fig3c" "fig3b")

# Extract Results
for i in {0..3}
do
        workload=${workloadarr[i]}
        figure=${figurearr[i]}
        output="$figure.data"

        if [ -f $output ]; then
                rm $output
        fi
        touch $output
        echo "# thread pm_only nvme_only orthus spfs polystore_static polystore_dynamic" > $output
        LINE=2

        for j in {0..4}
        do
                thread=${threadarr[j]}
                echo "$thread " >> $output
                
                if [ ! -f $result_dir/pmonly/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'FAST thruput [0-9]*.[0-9]*' $result_dir/pmonly/$workload/$thread/result.txt | sed 's/FAST thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/nvmeonly/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'SLOW thruput [0-9]*.[0-9]*' $result_dir/nvmeonly/$workload/$thread/result.txt | sed 's/SLOW thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output
                
                if [ ! -f $result_dir/orthus/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'aggregated thruput [0-9]*.[0-9]*' $result_dir/orthus/$workload/$thread/result.txt | sed 's/aggregated thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/spfs/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'aggregated thruput [0-9]*.[0-9]*' $result_dir/spfs/$workload/$thread/result.txt | sed 's/aggregated thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/polystore-static/$workload/$thread/result.txt ]; then
                        num=NA
                else               
                        num="`grep -o 'aggregated thruput [0-9]*.[0-9]*' $result_dir/polystore-static/$workload/$thread/result.txt | sed 's/aggregated thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/polystore-dynamic/$workload/$thread/result.txt ]; then
                        num=NA
                else                
                        num="`grep -o 'aggregated thruput [0-9]*.[0-9]*' $result_dir/polystore-dynamic/$workload/$thread/result.txt | sed 's/aggregated thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                let LINE=LINE+1
        done
done
