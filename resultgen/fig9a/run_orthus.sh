#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig9a

# Output result directory
result_dir=$RESULTS_PATH/fig9a/orthus

# Setup parameters
GRAPHFILE=$ORTHUS_DIR/graph.txt

FlushDisk() {
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo sh -c "sync"
        sudo sh -c "sync"
        sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

ResetFiles() {
	rm -rf $ORTHUS_DIR/graph.txt
	rm -rf $ORTHUS_DIR/graph.txt_GraphWalker/
}

FlushDisk

if [ ! -d "$result_dir" ]; then
        mkdir -p $result_dir
fi

# Copy Graph
echo "copying dataset to the working directory ..."
ResetFiles
cp $GRAPHDATASET_PATH/com-friendster.ungraph.txt $GRAPHFILE
echo "finishing copying dataset to the working directory"

echo "start running GraphWalker MSPRR"

# Run benchmark
cd $GRAPHWALKER_PATH
#LOG_LEVEL="debug" ./bin/apps/msppr file $GRAPHFILE firstsource 0 numsources 2000 walkspersource 2000 maxwalklength 100 prob 0.2 execthreads 16
LOG_LEVEL="debug" ./bin/apps/msppr file $GRAPHFILE firstsource 0 numsources 20000 walkspersource 20000 maxwalklength 100 prob 0.2 execthreads 16 &> $result_dir/result.txt
cd -

echo "finish running GraphWalker MSPRR"

FlushDisk
sleep 2
