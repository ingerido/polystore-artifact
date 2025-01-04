#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig6_c_d

# Output result directory
result_dir=$RESULTS_PATH/fig6_c_d/nvmeonly/

# Setup parameters
declare -a cachesizearr=("2" "4" "8" "16" "32")
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

total_mem_size=$(awk '/MemTotal/ {printf "%d\n", $2/1024/1024}' /proc/meminfo)

# Run benchmark
for i in {0..4}
do
        cachesize=${cachesizearr[i]}
        $BASE/scripts/memstress.sh $((total_mem_size - cachesize))

        for j in {0..3}
        do
                workload=${workloadarr[j]}
                workloadid=${workloadidarr[j]}
                thread=32
                output="$result_dir/$workload/$cachesize"
                if [ ! -d "$output" ]; then
                        mkdir -p $output
                fi
                if [ $j -eq 0 ]
                then
                        ResetFiles
                        FlushDisk
                fi

                echo "start $workload $cachesize"

                echo "WORKLOADID"$workloadid

                numactl --cpunodebind=0 $MICROBENCH_PATH/hetero_io_bench -r $thread -j $workloadid -s 4096 -t 1 -y 0 -x 0 -z 1g -f 5 -d 1 &> $output/result.txt

                echo "end $workload $thread"
                FlushDisk
                sleep 2
        done

        $BASE/scripts/memrelief.sh
done
