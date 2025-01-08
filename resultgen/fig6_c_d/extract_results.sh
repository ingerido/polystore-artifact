#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig6_c_d

# Output result directory
result_dir=$RESULTS_PATH/fig6_c_d

# Setup parameters
declare -a ratioarr=("2" "4" "8" "16" "32")
declare -a workloadarr=("randread" "randwrite")
declare -a figurearr=("fig6c" "fig6d")

# Extract Results
for i in {0..1}
do
        workload=${workloadarr[i]}
        figure=${figurearr[i]}
        output="$figure.data"

        if [ -f $output ]; then
                rm $output
        fi
        touch $output
        echo "# ratio pm_only nvme_only orthus spfs polystore_polycache" > $output
        LINE=2

        for j in {0..4}
        do
                ratio=${ratioarr[j]}
                ratio_legend=$((32/ratio)):1
                echo "$ratio_legend " >> $output
                
                if [ ! -f $result_dir/pmonly/$workload/$ratio/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'FAST thruput [0-9]*.[0-9]*' $result_dir/pmonly/$workload/$ratio/result.txt | sed 's/FAST thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/nvmeonly/$workload/$ratio/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'SLOW thruput [0-9]*.[0-9]*' $result_dir/nvmeonly/$workload/$ratio/result.txt | sed 's/SLOW thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output
                
                if [ ! -f $result_dir/orthus/$workload/$ratio/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'aggregated thruput [0-9]*.[0-9]*' $result_dir/orthus/$workload/$ratio/result.txt | sed 's/aggregated thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/spfs/$workload/$ratio/result.txt ]; then
                        num=NA
                else
                        num="`grep -o 'aggregated thruput [0-9]*.[0-9]*' $result_dir/spfs/$workload/$ratio/result.txt | sed 's/aggregated thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/polystore-polycache/$workload/$ratio/result.txt ]; then
                        num=NA
                else               
                        num="`grep -o 'aggregated thruput [0-9]*.[0-9]*' $result_dir/polystore-polycache/$workload/$ratio/result.txt | sed 's/aggregated thruput //'1`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                let LINE=LINE+1
        done
done
