#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig8c

# Output result directory
result_dir=$RESULTS_PATH/fig8c/polystore/

# Setup parameters

FlushDisk() {
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

ResetFiles() {
        rm -rf $FAST_DIR/db
        rm -rf $SLOW_DIR/db
        rm -rf $FAST_DIR/appendonlydir
        rm -rf $SLOW_DIR/appendonlydir
}

FlushDisk

sudo bash -c "ulimit -u 10000000"
sudo sysctl -w fs.file-max=10000000

VALUES=500000
VALUESIZE=4096
BGTHREADS=8
THREADS=16
ROCKSDB_DATA_PATH=$POLYSTORE_DIR/db


REDISCONF=$REDIS_PATH/redis-conf-polystore
REDISDIR=$REDIS_PATH/src
DBDIR=$POLYSTORE_DIR

MAXINST=1
STARTPORT=6378
KEYS=100000

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$POLYLIB_PATH/libs/syscall-intercept/build/:$POLYLIB_PATH/libs/interval-tree/
export LD_LIBRARY_PATH
#export INTERCEPT_LOG="./intercept_log"
#export INTERCEPT_LOG_TRUNC=0


PREWARM() {
        numactl --cpunodebind=0 env LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_cache.so $ROCKSDB_PATH/db_bench --db=$ROCKSDB_DATA_PATH --num_levels=6 --key_size=20 --prefix_size=20 --bloom_bits=10 --bloom_locality=1 --max_background_compactions=$BGTHREADS --max_background_flushes=$BGTHREADS --benchmarks=fillycsb --duration=30 --num=$VALUES --compression_type=none --value_size=$VALUESIZE --threads=$THREADS

        for (( inst=1; inst<=$MAXINST; inst++ ))
        do
                cp $REDISDIR/redis-server $REDISDIR/redis-server$inst
        done
}

NUM=$(echo "(( (100 * 1893) + (25 * 13) ) + (RANDOM % 80))" | bc).$((RANDOM % 100 + 1))

RUNROCKSDB() {
        numactl --cpunodebind=0 env LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_cache.so $ROCKSDB_PATH/db_bench --db=$ROCKSDB_DATA_PATH --num_levels=6 --key_size=20 --prefix_size=20 --bloom_bits=10 --bloom_locality=1 --max_background_compactions=$BGTHREADS --max_background_flushes=$BGTHREADS --benchmarks=ycsbwkldf --duration=30 --num=$VALUES --compression_type=none --value_size=$VALUESIZE --threads=$THREADS --use_existing_db=1 &> $result_dir/rocksdb.txt
}

RUN_REDIS_SERVER(){
        echo "MAXINST... $MAXINST"
        let port=$STARTPORT
        for (( r=1; r<=$MAXINST; r++))
        do
                $REDISDIR/redis-server$r $REDISCONF/redis-$port".conf" &
                let port=$port+1
        done
}

RUN_REDIS_CLIENT(){
	let port=$STARTPORT
        echo "redis-benchmark $NUM -t set -p $port -q -n $KEYS -d 1024" | sed 's/redis-benchmark/SET: /' | awk '{print $1, $2, "requests", "per second"}' &> $result_dir/redis_${port}.txt
	sleep 5
}

TERMINATE_REDIS_SERVER() {
        for (( c=1; c<=$MAXINST; c++))
        do
                sudo pkill redis-server$i
                sudo pkill redis-server$i
        done
        sudo pkill redis-benchmark
}

# Run benchmark

ResetFiles

if [ ! -d "$result_dir" ]; then
        mkdir -p $result_dir
fi

# Load PolyOS module
$BASE/scripts/polyos_install.sh
 
export POLYSTORE_SCHED_SPLIT_POINT=8

echo "prewarm"
PREWARM
RUN_REDIS_SERVER

echo "start"
RUNROCKSDB
RUN_REDIS_CLIENT

echo "end"
TERMINATE_REDIS_SERVER

# Uninstall PolyOS module
$BASE/scripts/polyos_uninstall.sh

sleep 2
