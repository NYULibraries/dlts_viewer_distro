#!/bin/bash

total=2984

count=`ls -1 ./data/*.json | wc -l | xargs`

while [ $count -lt $total ] ; do
  node app.js --start=${count} --rows=50;
  sleep 1
  count=`ls -1 ./data/*.json | wc -l | xargs`  
done

exit 0
