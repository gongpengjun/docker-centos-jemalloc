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

```shell
[root@0bf8b75b4770 diagnostic]# ./nmt-baseline.sh
39:
Baseline succeeded
[root@0bf8b75b4770 diagnostic]# ./nmt-diff.sh
39:

Native Memory Tracking:

Total: reserved=2022647KB +201KB, committed=722655KB +201KB
...
```

定时查看nmt结果

```shell
[root@560ed375bbdc diagnostic]# ./log-nmt-reports.sh &
[1] 9933
[root@8a159c9c4261 diagnostic]# ./format-nmt-report.sh
File Name                     Java Heap  Class  Thread  Code   GC      Compiler  Internal  Symbol  Native Memory Tracking  Arena Chunk  Unknown  Total
reports/nmt_202105181425.out  524,288    5,003  36,012  2,590  72,959  138       2,119     73,620  450                     195          0        717,374
reports/nmt_202105181426.out  524,288    5,007  36,012  2,592  73,354  138       2,136     77,316  467                     196          0        721,505
reports/nmt_202105181427.out  524,288    5,007  36,012  2,592  73,487  138       2,136     77,316  468                     196          0        721,640
```

### 1.3.5 Run jeprof

```shell
[root@0bf8b75b4770 diagnostic]# cat jeprof-reports.sh
#!/bin/bash

jeprof --svg /tmp/jeprof.* > /tmp/jprof/jeprof-report.svg 2>/dev/null
jeprof --text /tmp/jeprof.* > /tmp/jprof/jeprof-report.txt 2>/dev/null

[root@0bf8b75b4770 diagnostic]# ./jeprof-reports.sh
[root@0bf8b75b4770 diagnostic]# ls /tmp/jprof/
jeprof-report.svg  jeprof-report.txt
```

导出jeprof结果

```shell
docker-centos-jemalloc$ docker cp 0bf8b75b4770:/tmp/jprof ./
docker-centos-jemalloc$ ls jprof/
jeprof-report.svg	jeprof-report.txt
docker-centos-jemalloc$ open -a /Applications/Google\ Chrome.app jprof/jeprof-report.svg
```



## 2. jemalloc usage - jeprof

- [jemalloc](http://jemalloc.net/)

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

## 
