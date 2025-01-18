#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig7

# Output result directory
result_dir=$RESULTS_PATH/fig7

# Setup parameters
declare -a threadarr=("1" "4" "16" "32")
declare -a workloadarr=("varmail" "fileserver")
declare -a figurearr=("fig7a" "fig7b")

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
        echo "# thread pm_only nvme_only orthus spfs polystore" > $output
        LINE=2

        for j in {0..3}
        do
                thread=${threadarr[j]}
                echo "$thread " >> $output
                
                if [ ! -f $result_dir/pmonly/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`awk '/IO Summary/ {print}' $result_dir/pmonly/$workload/$thread/result.txt | sed -n 's/.* \([0-9.]*\) ops\/s.*/\1/p'`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/nvmeonly/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`awk '/IO Summary/ {print}' $result_dir/nvmeonly/$workload/$thread/result.txt | sed -n 's/.* \([0-9.]*\) ops\/s.*/\1/p'`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output
                
                if [ ! -f $result_dir/orthus/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`awk '/IO Summary/ {print}' $result_dir/orthus/$workload/$thread/result.txt | sed -n 's/.* \([0-9.]*\) ops\/s.*/\1/p'`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/spfs/$workload/$thread/result.txt ]; then
                        num=NA
                else
                        num="`awk '/IO Summary/ {print}' $result_dir/spfs/$workload/$thread/result.txt | sed -n 's/.* \([0-9.]*\) ops\/s.*/\1/p'`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                if [ ! -f $result_dir/polystore/$workload/$thread/result.txt ]; then
                        num=NA
                else               
                        num="`awk '/IO Summary/ {print}' $result_dir/polystore/$workload/$thread/result.txt | sed -n 's/.* \([0-9.]*\) ops\/s.*/\1/p'`"
                fi
                sed -i -e "$LINE s/$/ $num/" $output

                let LINE=LINE+1
        done
done
