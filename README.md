# Java NMT and jemalloc Debug sample
[TOC]

## 1. Usage

## 1.1 Download JDK 8

Goto https://www.oracle.com/java/technologies/javase-downloads.html
Download `jdk-8u291-linux-x64.tar.gz` and move alongside of beside by Dockerfile.


## 1.2 Build Docker Image

```shell
$ docker build . -t centos-jdk8-jemalloc:8u291
```

## 1.3 Debug sample

### 1.3.1 launch docker container

```shell
$ docker run -ti --rm centos-jdk8-jemalloc:8u291
```

>  👇 all the following operations are running in the docker container

### 1.3.2 Compile Java App - StringInterner

```shell
[root@0bf8b75b4770 diagnostic]# javac sample/StringInterner.java
[root@0bf8b75b4770 diagnostic]# ls sample/
StringInterner.class  StringInterner.java
```

### 1.3.3 Launch Java App - StringInterner

http://jenshadlich.blogspot.com/2016/08/find-native-memory-leaks-in-java.html

Enable NMT and jemalloc profiling

```shell
[root@0bf8b75b4770 diagnostic]# cat run-interner.sh
#!/bin/bash
export LD_PRELOAD=/usr/local/lib/libjemalloc.so
export MALLOC_CONF="prof_leak:true,prof:true,lg_prof_interval:25,lg_prof_sample:18,prof_prefix:/tmp/jeprof"
#export MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true

#java -XX:NativeMemoryTracking=detail -cp /opt/StringInterner StringInterner &

java -XX:NativeMemoryTracking=detail -XX:+UseG1GC -XX:MetaspaceSize=100m -XX:MaxMetaspaceSize=100m \
     -Xloggc:/tmp/gc-jdk8-g1.log -Xms512m -Xmx512m -cp /diagnostic/sample StringInterner &

[root@0bf8b75b4770 diagnostic]# ./run-interner.sh
```

### 1.3.4 Run NMT Check

#### 1.3.4.1 定时查看NMT摘要

```shell
[root@45845145f074 diagnostic]# ./run-interner.sh
[root@45845145f074 diagnostic]# ./log-nmt-summary.sh
Time,Java_Heap,Class,Thread,Code,GC,Compiler,Internal,Symbol,Native_Memory_Tracking,Arena_Chunk,Unknown
06:11:07,524288KB,5003KB,36012KB,2590KB,72811KB,138KB,1985KB,63868KB,413KB,195KB,0KB
06:11:18,524288KB,5003KB,36012KB,2590KB,72942KB,138KB,2077KB,73388KB,445KB,195KB,0KB
06:11:28,524288KB,5003KB,36012KB,2590KB,72957KB,138KB,2120KB,73388KB,450KB,195KB,0KB
```

#### 1.3.4.2 定时查看NMT摘要增量

```shell
[root@45845145f074 diagnostic]# ./run-interner.sh
[root@45845145f074 diagnostic]# ./log-nmt-diff.sh
2021-05-19 04:02:18
73:
Baseline succeeded
Time,Java_Heap,Class,Thread,Code,GC,Compiler,Internal,Symbol,Native_Memory_Tracking,Arena_Chunk,Unknown
04:02:19,524288KB,5003KB,36012KB,2591KB,72754KB,138KB,1883KB,59956KB+4296KB,419KB+32KB,2059KB,0KB
04:02:24,524288KB,5003KB,36012KB,2591KB,72895KB+141KB,138KB,2096KB+213KB,73452KB+17792KB,471KB+84KB,196KB-1863KB,0KB
04:02:29,524288KB,5003KB,36012KB,2591KB,72897KB+143KB,138KB,2100KB+217KB,73452KB+17792KB,472KB+85KB,196KB-1863KB,0KB
04:02:34,524288KB,5003KB,36012KB,2591KB,72955KB+201KB,138KB,2102KB+219KB,73452KB+17792KB,473KB+86KB,196KB-1863KB,0KB
04:02:39,524288KB,5003KB,36012KB,2591KB,72961KB+207KB,138KB,2120KB+237KB,73452KB+17792KB,475KB+88KB,196KB-1863KB,0KB
04:02:45,524288KB,5003KB,36012KB,2591KB,72961KB+207KB,138KB,2120KB+237KB,73452KB+17792KB,475KB+88KB,196KB-1863KB,0KB
```

### 1.3.5 Run jeprof

```shell
[root@0bf8b75b4770 diagnostic]# cat jeprof-reports.sh
#!/bin/bash

jeprof --svg /tmp/jeprof.* > /tmp/jeprof/jeprof-report.svg 2>/dev/null
jeprof --text /tmp/jeprof.* > /tmp/jeprof/jeprof-report.txt 2>/dev/null

[root@0bf8b75b4770 diagnostic]# ./jeprof-reports.sh
[root@0bf8b75b4770 diagnostic]# ls /tmp/jeprof/
jeprof-report.svg  jeprof-report.txt
```

导出jeprof结果

```shell
docker-centos-jemalloc$ docker cp 0bf8b75b4770:/tmp/jeprof ./
docker-centos-jemalloc$ ls jeprof/
jeprof-report.svg	jeprof-report.txt
docker-centos-jemalloc$ open -a /Applications/Google\ Chrome.app jeprof/jeprof-report.svg
```



## 2. jemalloc usage - jeprof

### 2.1 Configure ENV

Configure Java to use jemalloc using **LD_PRELOAD**.

```shell
LD_PRELOAD=/usr/local/lib/libjemalloc.so
```

Enable profiling using **MALLOC_CONF**.

```shell
MALLOC_CONF="prof_leak:true,prof:true,lg_prof_interval:25,lg_prof_sample:18,prof_prefix:/tmp/jeprof"
```

### 2.2 jeprof Reports

Use jeprof to produce a text report or a nice graph over the
allocations – eventually the leak should stand out.

#### 2.2.1 Graphical report

```shell
$ jeprof --svg /tmp/jeprof.* > jeprof-report.svg
```

#### 2.2.2 Text report

```shell
$ jeprof --text /tmp/jeprof.* > jeprof.txt
```

## 3. Reference

jcmd：https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/tooldescr006.html

NMT：https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/tooldescr007.html

jemalloc： http://jemalloc.net/

Centos Docker Offical Image：https://hub.docker.com/_/centos



