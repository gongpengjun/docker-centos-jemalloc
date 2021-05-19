#!/bin/bash

PID=$(pgrep java)
COUNT=60
INTERVAL=10

jcmd ${PID} VM.native_memory summary | grep "(reserved=" | sed 's/- *\(.*\) (reserved=.*/\1/' | sed 's/ /_/g' | xargs echo Time | sed 's/ /,/g'

COUNTER=0
while [ $COUNTER -lt $COUNT ];
do
  jcmd ${PID} VM.native_memory summary scale=KB | grep "(reserved=" | sed 's/.*committed=\([0-9]*KB\).*/\1/' | xargs echo $(date +'%H:%M:%S') | sed 's/ /,/g'
  sleep ${INTERVAL}
  let COUNTER=COUNTER+1
done

