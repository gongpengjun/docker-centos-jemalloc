#!/bin/bash

PID=$(pgrep java)
COUNT=60
INTERVAL=10

mkdir -p reports
COUNTER=0
while [ $COUNTER -lt $COUNT ];
do
  jcmd ${PID} VM.native_memory summary > reports/nmt_$(date +"%Y%m%d%H%M").out
  sleep ${INTERVAL}
  let COUNTER=COUNTER+1
done

# reserved表示应用可用的内存大小， committed表示应用正在使用的内存大小
# nmt-tools/nmt-parser.py --files reports/nmt*.out --mode committed | column -t -s ';'

