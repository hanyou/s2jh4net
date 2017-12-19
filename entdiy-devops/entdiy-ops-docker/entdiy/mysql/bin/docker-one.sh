#!/bin/sh

SHELL_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
BASE_DIR=${SHELL_DIR}/..

app_name="mysql"
port="3306"

while getopts p:c: opt
do
  case $opt in
    p)
      port="$OPTARG"
    ;;    
  esac
done
shift $((OPTIND-1))

data_dir=${BASE_DIR}/data
config_dir=${BASE_DIR}/config
log_dir=${BASE_DIR}/logs
docker_name=${app_name}-${port}

case "$1" in
    start)
    echo docker run ${docker_name}...
    mkdir -p ${data_dir}; mkdir -p ${config_dir}; mkdir -p ${log_dir}
    docker run --name ${docker_name} -p $port:3306 --restart=always --privileged=true \
                -v $data_dir:/var/lib/mysql \
                -v $config_dir:/etc/entdiy/config \
                -e MYSQL_ROOT_PASSWORD=entdiy \
                -e TZ="Asia/Shanghai" \
                -d mysql:5.7.20

    echo docker started for $docker_name.
    ;;
    stop)
    cids=$(docker ps -aq --filter "name=$docker_name")
    if [ "$cids" == "" ]; then
       echo "Not running"
    else
       echo docker stop and rm container $docker_name...
       docker stop -t 10 $cids && docker rm $cids
       echo docker stopped for $docker_name.
    fi
    ;;
    restart)
    $0 -p $port stop
    $0 -p $port start
    ;;
    status)
    cids=$(docker ps -aq --filter "name=$docker_name")
    if [ "$cids" == "" ]; then
       echo "Not running"
    else
       docker ps -a --filter "name=$docker_name"
    fi
    ;;
    stop)
    cids=$(docker ps -aq --filter "name=$docker_name")
    if [ "$cids" == "" ]; then
       echo "Not running"
    else
       echo docker stop and rm container $docker_name...
       docker stop -t 10 $cids && docker rm $cids
       echo docker stopped for $docker_name.
    fi
    ;;
    init)
    seconds=10
    echo "Sleep ${seconds}s to wait mysql start and execute database init..."
    printf "Sleeping ";while(( seconds >0 )); do
      printf .
      ((seconds--))
      sleep 1s
    done
    sql="CREATE DATABASE entdiy DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    docker exec -i $docker_name mysql -h localhost -u root -pentdiy <<< "${sql}"
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|init|status}"
    exit 1
    ;;
esac
exit 0
