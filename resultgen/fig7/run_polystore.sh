#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig7

# Output result directory
result_dir=$RESULTS_PATH/fig7/polystore/

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

        if [ -d $SLOW_DIR/bigfileset ]; then
                rm -rf $SLOW_DIR/bigfileset/*
        fi
}

FlushDisk

sudo bash -c "ulimit -u 10000000"
sudo sysctl -w fs.file-max=10000000

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$POLYLIB_PATH/libs/syscall-intercept/build/:$POLYLIB_PATH/libs/interval-tree/
export LD_LIBRARY_PATH
#export INTERCEPT_LOG="./intercept_log"
#export INTERCEPT_LOG_TRUNC=0

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

                # Load PolyOS module
                $BASE/scripts/polyos_install.sh

                export POLYSTORE_SCHED_SPLIT_POINT=8
                export POLYSTORE_POLYCACHE_POLICY=2
                export THREAD_COUNT=$thread
                export WORKLOAD=$i

                numactl --cpunodebind=0 env LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_cache_shm.so $FILEBENCH_PATH/filebench -f $FILEBENCH_PATH/workloads_polystore/${workload}_${thread}.f &> $output/result.txt

                # Uninstall PolyOS module
                $BASE/scripts/polyos_uninstall.sh 

                unset POLYSTORE_SCHED_SPLIT_POINT
                unset POLYSTORE_POLYCACHE_POLICY
                unset THREAD_COUNT
                unset WORKLOAD

                echo "end $workload $thread"
                FlushDisk
                sleep 2
        done
done

echo 2 | sudo tee /proc/sys/kernel/randomize_va_space
