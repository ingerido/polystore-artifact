#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig8a

# Output result directory
result_dir=$RESULTS_PATH/fig8a/polystore/

# Setup parameters
declare -a workloadarr=("a" "b" "c" "d" "e" "f")
declare -a benchmarkarr=("fillycsb" "ycsbwklda" "ycsbwkldb" "ycsbwkldc" "ycsbwkldd" "ycsbwklde" "ycsbwkldf")
declare -a parameterarr=("" "--use_existing_db=1" "--use_existing_db=1")

FlushDisk() {
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

ResetFiles() {
        rm -rf $FAST_DIR/db
        rm -rf $SLOW_DIR/db
}

FlushDisk

sudo bash -c "ulimit -u 10000000"
sudo sysctl -w fs.file-max=10000000

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$POLYLIB_PATH/libs/syscall-intercept/build/:$POLYLIB_PATH/libs/interval-tree/
export LD_LIBRARY_PATH
#export INTERCEPT_LOG="./intercept_log"
#export INTERCEPT_LOG_TRUNC=0

VALUES=500000
VALUESIZE=4096
BGTHREADS=8
THREADS=16
DBDATA_PATH=$POLYSTORE_DIR/db

# Load PolyOS module
$BASE/scripts/polyos_install.sh

export POLYSTORE_SCHED_SPLIT_POINT=8

# Run benchmark
for i in {0..6}
do
        benchmark=${benchmarkarr[i]}
        param=${parameterarr[i]} 
        if [ $i -eq 0 ]; then
                ResetFiles
        fi

        output="$result_dir/$benchmark/"
        if [ ! -d "$output" ]; then
                mkdir -p $output
        fi
        echo "start $benchmark"

        numactl --cpunodebind=0 env LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_cache.so $ROCKSDB_PATH/db_bench --db=$DBDATA_PATH --num_levels=6 --key_size=20 --prefix_size=20 --bloom_bits=10 --bloom_locality=1 --max_background_compactions=$BGTHREADS --max_background_flushes=$BGTHREADS --benchmarks=$benchmark --duration=30 --num=$VALUES --compression_type=none --value_size=$VALUESIZE --threads=$THREADS $param &> $output/result.txt

        echo "end $benchmark"

        sleep 2
done

# Uninstall PolyOS module
$BASE/scripts/polyos_uninstall.sh
