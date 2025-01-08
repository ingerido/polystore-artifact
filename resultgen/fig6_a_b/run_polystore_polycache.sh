#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig6_a_b

# Output result directory
result_dir=$RESULTS_PATH/fig6_a_b/polystore-polycache/

# Setup parameters
declare -a threadarr=("2" "4" "8" "16" "32")
declare -a workloadarr=("seqwrite" "randread" "randwrite" "seqread")
declare -a workloadidarr=("2" "3" "4" "1")

FlushDisk() {
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

ResetFiles() {
        rm -rf $FAST_DIR/.persist/
        for t in {0..31}
        do
                if [ ! -f $FAST_DIR/thread_$t ]; then
                        touch $FAST_DIR/thread_$t
                else
                        truncate -s 0 $FAST_DIR/thread_$t
                fi

                if [ ! -f $SLOW_DIR/thread_$t ]; then
                        touch $SLOW_DIR/thread_$t
                else
                        truncate -s 0 $SLOW_DIR/thread_$t
                fi
        done
}

# Generate Testing files in FAST and SLOW device
if [ ! -d $FAST_DIR ]; then
        mkdir $FAST_DIR
fi

if [ ! -d $SLOW_DIR ]; then
        mkdir $SLOW_DIR
fi

FlushDisk

export HETERO_DIR=$POLYSTORE_DIR

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$POLYLIB_PATH/libs/syscall-intercept/build/:$POLYLIB_PATH/libs/interval-tree/
export LD_LIBRARY_PATH
#export INTERCEPT_LOG="./intercept_log"
#export INTERCEPT_LOG_TRUNC=0

# Run benchmark
for i in {0..4}
do
        thread=${threadarr[i]}
        export POLYSTORE_SCHED_SPLIT_POINT=$((thread + 4))
        export POLYSTORE_POLYCACHE_POLICY=2

        # Load PolyOS module
        $BASE/scripts/polyos_install.sh

        for j in {0..3}
        do
                workload=${workloadarr[j]}
                workloadid=${workloadidarr[j]}
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

                numactl --cpunodebind=0 env LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_cache.so $MICROBENCH_PATH/hetero_io_bench_transparent -r $thread -j $workloadid -s 4096 -t 2 -y 0 -x 0 -z 1g -f 1 -d 1 &> $output/result.txt

                echo "end $workload $thread"
                FlushDisk
                sleep 2
        done

        unset POLYSTORE_SCHED_SPLIT_POINT
        unset POLYSTORE_POLYCACHE_POLICY

        # Uninstall PolyOS module
        $BASE/scripts/polyos_uninstall.sh
done
