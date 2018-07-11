#!/bin/bash

[ $# == 0 ] && exit 1

action=$1
name=nifi
container_id=container_id

if [ "$action" == "run" ]
then
  [ -f $container_id ] && docker rm $(cat $container_id)
#  HDFS_HOST=172.17.0.3
  docker run -p 8080:8080 -e "NIFI_WEB_HTTP_HOST=test" \
    -e "HDFS_URL=hdfs://172.17.0.3:8020" -e "HDFS_HOST=172.17.0.3" --name $name -d $name > $container_id
  #sudo docker run -p 8080:8080 --name $name -d $name > $container_id
elif [ "$action" == "stop" ]
then
  docker stop $(cat $container_id)
elif [ "$action" == "bash" ]
then
  docker exec -it $name bash
elif [ "$action" == "logs" ]
then
  docker logs $(cat $container_id)
elif [ "$action" == "build" ]
then
  docker build --tag $name .
elif [ "$action" == "push" ]
then
  [ $# != 3 ] && echo "Missing parameters: <your docker id> <version>" && exit 1
  docker tag $name $2/$name:$3
  docker push $2/$name:$3
else
  echo "Unknown command: $1"
  echo "Commands:"
  echo "  run"
  echo "  stop"
  echo "  bash"
  echo "  logs"
  echo "  build"
  echo "  push <your docker id> <version>"
fi

