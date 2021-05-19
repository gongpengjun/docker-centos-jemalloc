#!/bin/bash

PID=$(pgrep java)
COUNT=60
INTERVAL=5

# set baseline
date +'%F %H:%M:%S'
jcmd ${PID} VM.native_memory baseline scale=KB

jcmd ${PID} VM.native_memory summary | grep "(reserved=" | sed 's/- *\(.*\) (reserved=.*/\1/' | sed 's/ /_/g' | xargs echo Time | sed 's/ /,/g'

COUNTER=0
while [ $COUNTER -lt $COUNT ];
do
  jcmd ${PID} VM.native_memory summary.diff scale=KB | grep "(reserved=" | sed -e 's/.*committed=\(.*KB\)).*/\1/' -e 's/ //g' | xargs echo $(date +'%H:%M:%S') | sed 's/ /,/g'
  sleep ${INTERVAL}
  let COUNTER=COUNTER+1
done

#jcmd 3337 VM.native_memory baseline scale=KB
#jcmd 3337 VM.native_memory summary.diff scale=KB | grep "(reserved=" | sed -e 's/.*committed=\(.*KB\)).*/\1/' -e 's/ //g' | xargs echo $(date +'%H:%M:%S') | sed 's/ /,/g'
