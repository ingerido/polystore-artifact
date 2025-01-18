#!/bin/bash

cd ../../
source scripts/setvars.sh
cd resultgen/fig8c

# Output result directory
result_dir=$RESULTS_PATH/fig8c

# Extract Results
output="fig8c.data"

if [ -f $output ]; then
        rm $output
fi
touch $output
echo "# workload pm_only nvme_only orthus spfs polystore" > $output

rocksdb_result="rocksdb.txt"
redis_result="redis_6378.txt"

echo "RocksDB" >> $output

if [ ! -f $result_dir/pmonly/$rocksdb_result ]; then
        num=NA
else
        num="`awk '/ycsbwkld/ {print}' $result_dir/pmonly/$rocksdb_result | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
fi
sed -i -e "2 s/$/ $num/" $output

if [ ! -f $result_dir/nvmeonly/$rocksdb_result ]; then
        num=NA
else
        num="`awk '/ycsbwkld/ {print}' $result_dir/nvmeonly/$rocksdb_result | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
fi
sed -i -e "2 s/$/ $num/" $output

if [ ! -f $result_dir/orthus/$rocksdb_result ]; then
        num=NA
else
        num="`awk '/ycsbwkld/ {print}' $result_dir/orthus/$rocksdb_result | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
fi
sed -i -e "2 s/$/ $num/" $output

if [ ! -f $result_dir/spfs/$rocksdb_result ]; then
        num=NA
else
        num="`awk '/ycsbwkld/ {print}' $result_dir/spfs/$rocksdb_result | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
fi
sed -i -e "2 s/$/ $num/" $output

if [ ! -f $result_dir/polystore/$rocksdb_result ]; then
        num=NA
else
        num="`awk '/ycsbwkld/ {print}' $result_dir/polystore/$rocksdb_result | sed -n 's/.* \([0-9.]*\) ops\/sec.*/\1/p'`"
fi
sed -i -e "2 s/$/ $num/" $output


echo "Redis" >> $output

if [ ! -f $result_dir/pmonly/$redis_result ]; then
        num=NA
else
        echo ""
        num="`grep -o '[0-9]*\.[0-9]* requests per second' $result_dir/pmonly/$redis_result | sed 's/\.*[0-9]* requests per second//'1`"
fi
sed -i -e "3 s/$/ $num/" $output

if [ ! -f $result_dir/nvmeonly/$redis_result ]; then
        num=NA
else
        echo ""
        num="`grep -o '[0-9]*\.[0-9]* requests per second' $result_dir/nvmeonly/$redis_result | sed 's/\.*[0-9]* requests per second//'1`"
fi
sed -i -e "3 s/$/ $num/" $output

if [ ! -f $result_dir/orthus/$redis_result ]; then
        num=NA
else
        echo ""
        num="`grep -o '[0-9]*\.[0-9]* requests per second' $result_dir/orthus/$redis_result | sed 's/\.*[0-9]* requests per second//'1`"
fi
sed -i -e "3 s/$/ $num/" $output

if [ ! -f $result_dir/spfs/$redis_result ]; then
        num=NA
else
        echo ""
        num="`grep -o '[0-9]*\.[0-9]* requests per second' $result_dir/spfs/$redis_result | sed 's/\.*[0-9]* requests per second//'1`"
fi
sed -i -e "3 s/$/ $num/" $output

if [ ! -f $result_dir/polystore/$redis_result ]; then
        num=NA
else
        echo ""
        num="`grep -o '[0-9]*\.[0-9]* requests per second' $result_dir/polystore/$redis_result | sed 's/\.*[0-9]* requests per second//'1`"
fi
sed -i -e "3 s/$/ $num/" $output

