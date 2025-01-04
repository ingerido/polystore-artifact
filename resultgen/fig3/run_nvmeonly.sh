#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig3

# Output result directory
result_dir=$RESULTS_PATH/fig3/nvmeonly/

# Setup parameters
declare -a threadarr=("2" "4" "8" "16" "32")
declare -a thresholdarr=("1" "2" "4" "8" "8")
declare -a workloadarr=("seqwrite" "randread" "randwrite" "seqread")
declare -a workloadidarr=("2" "3" "4" "1")

FlushDisk() {
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

ResetFiles() {
        for t in {0..31}
        do
                if [ ! -f $SLOW_DIR/thread_$t ]; then
                        touch $SLOW_DIR/thread_$t
                else
                        truncate -s 0 $SLOW_DIR/thread_$t
                fi
        done
}

# Generate Testing files in FAST and SLOW device
if [ ! -d $SLOW_DIR ]; then
        mkdir $SLOW_DIR
fi

FlushDisk

# Run benchmark
for i in {0..4}
do
        for j in {0..3}
        do
                workload=${workloadarr[j]}
                workloadid=${workloadidarr[j]}
                thread=${threadarr[i]}
                output="$result_dir/$workload/$thread"
                if [ ! -d "$output" ]; then
                        mkdir -p $output
                fi
                if [ $j -eq 0 ]
                then
                        ResetFiles
                        FlushDisk
                fi
                echo "start $workload $thread"

                echo "WORKLOADID"$workloadid

                numactl --cpunodebind=0 $MICROBENCH_PATH/hetero_io_bench -r $thread -j $workloadid -s 4096 -t 2 -y 0 -x 0 -z 1g -f 5 -d 1 &> $output/result.txt

                echo "end $workload $thread"
                FlushDisk
                sleep 2
        done
done
