#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig9a

# Output result directory
result_dir=$RESULTS_PATH/fig9a/polystore

# Setup parameters
GRAPHFILE=$POLYSTORE_DIR/graph.txt

FlushDisk() {
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

ResetFiles() {
	rm -rf $FAST_DIR/.persist/
	rm -rf $FAST_DIR/graph.txt
	rm -rf $FAST_DIR/graph.txt_GraphWalker/
	rm -rf $SLOW_DIR/graph.txt
	rm -rf $SLOW_DIR/graph.txt_GraphWalker/
}

FlushDisk

if [ ! -d "$result_dir" ]; then
        mkdir -p $result_dir
fi

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$POLYLIB_PATH/libs/syscall-intercept/build/:$POLYLIB_PATH/libs/interval-tree/
export LD_LIBRARY_PATH
#export INTERCEPT_LOG="./intercept_log"
#export INTERCEPT_LOG_TRUNC=0

# Load PolyOS module
$BASE/scripts/polyos_install_large_index.sh

export POLYSTORE_SCHED_SPLIT_POINT=8

# Copy Graph
ResetFiles
LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_filecopy.so ../../tools/filecopy /mnt/dataset/com-friendster.ungraph.txt $GRAPHFILE

echo "start running GraphWalker MSPRR"

# Run benchmark
cd $GRAPHWALKER_PATH
#numactl --cpunodebind=0 env LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_dynamic.so LOG_LEVEL="debug" ./bin/apps/msppr file $GRAPHFILE firstsource 0 numsources 2000 walkspersource 2000 maxwalklength 100 prob 0.2 execthreads 16
numactl --cpunodebind=0 env LD_PRELOAD=$POLYLIB_PATH/build/libpolystore_dynamic.so LOG_LEVEL="debug" ./bin/apps/msppr file $GRAPHFILE firstsource 0 numsources 20000 walkspersource 20000 maxwalklength 100 prob 0.2 execthreads 16 &> $result_dir/result.txt
cd -

echo "finish running GraphWalker MSPRR"

FlushDisk
sleep 2

# Uninstall PolyOS module
$BASE/scripts/polyos_uninstall.sh

