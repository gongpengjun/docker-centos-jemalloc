#!/bin/bash

# http://jenshadlich.blogspot.com/2016/08/find-native-memory-leaks-in-java.html

# enables jemalloc being loaded before any other library which at runtime eventually replaces malloc of the C standard library.
export LD_PRELOAD=/usr/local/lib/libjemalloc.so

# lg_prof_interval sets average interval in allocated bytes (2^value) between dumps.
# leak profiling is enabled and is written to a file (like jeprof.<pid>.0.f.heap) when the program terminates.
# lg_prof_sample sets average interval in bytes (2^value) between allocation samples, default 19.
# prof_leak enable leak detection.
# prof enable profiling.
# prof_prefix where to write files.
export MALLOC_CONF="prof_leak:true,prof:true,lg_prof_interval:25,lg_prof_sample:18,prof_prefix:/tmp/jeprof"
#export MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true

#java -XX:NativeMemoryTracking=detail -cp /opt/StringInterner StringInterner &

java -XX:NativeMemoryTracking=detail -XX:+UseG1GC -XX:MetaspaceSize=100m -XX:MaxMetaspaceSize=100m \
     -Xloggc:/tmp/gc-jdk8-g1.log -Xms512m -Xmx512m -cp /diagnostic/sample StringInterner &

