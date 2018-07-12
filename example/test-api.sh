#!/bin/bash

jq=./jq-osx-amd64

saagie_user=<PUT HERE YOUR LOGIN>

curl https://saagie-manager.prod.saagie.io/ -u $saagie_user -c cookies.txt -s > /dev/null
pg=$(curl -s https://4-nifi.prod.saagie.io/nifi-api/process-groups/root -b cookies.txt)
uri=$(echo $pg | $jq -r '.uri')
id=$(echo $pg | $jq -r '.id')


# Start the process group
curl https://4-nifi.prod.saagie.io/nifi-api/flow/process-groups/$id \
  -b cookies.txt \
  -XPUT \
  -H 'Content-Type: application/json' \
  -d '{"id":"'$id'","state":"RUNNING"}'

sleep 30

# Stop the process group
curl https://4-nifi.prod.saagie.io/nifi-api/flow/process-groups/$id \
  -b cookies.txt \
  -XPUT \
  -H 'Content-Type: application/json' \
  -d '{"id":"'$id'","state":"STOPPED"}'
