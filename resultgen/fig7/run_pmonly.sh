#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig7

# Output result directory
result_dir=$RESULTS_PATH/fig7/pmonly/

# Setup parameters
declare -a threadarr=("1" "4" "16" "32")
declare -a workloadarr=("varmail" "fileserver")

FlushDisk() {
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

ResetFiles() {
        if [ -d $FAST_DIR/bigfileset ]; then
                rm -rf $FAST_DIR/bigfileset/*
        fi
}

FlushDisk

sudo bash -c "ulimit -u 10000000"
sudo sysctl -w fs.file-max=10000000

echo 0 | sudo tee /proc/sys/kernel/randomize_va_space

# Run benchmark
for i in {0..1}
do
        workload=${workloadarr[i]}
        ResetFiles
        FlushDisk

        for j in {0..3}
        do
                thread=${threadarr[j]} 
                output="$result_dir/$workload/$thread"
                if [ ! -d "$output" ]; then
                        mkdir -p $output
                fi
                echo "start $workload $thread"

                $FILEBENCH_PATH/filebench -f $FILEBENCH_PATH/workloads_pmonly/${workload}_${thread}.f &> $output/result.txt

                echo "end $workload $thread"
                FlushDisk
                sleep 2
        done
done

echo 2 | sudo tee /proc/sys/kernel/randomize_va_space
