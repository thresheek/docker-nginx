#!/bin/sh

set -eu

#tocheck="nginx:mainline nginx:mainline-alpine"
tocheck="nginx:mainline-alpine"

check() {
    cont=$(docker run -e NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1 $input -d $image)
    sleep 5
    result=$(docker exec -ti $cont grep ^worker_processes /etc/nginx/nginx.conf | cut -d' ' -f 2 | tr -d ';\n\r')
    docker stop $cont
    docker rm $cont
    if [ $result -ne $expect ]; then exit 1; fi
    return 0
}

for image in $tocheck; do
    input="--cpu-period 1000 --cpu-quota 4750 --cpuset-cpus 1,3,5,4,2,0"
    expect=5
    check
    input="--cpu-period 1000 --cpu-quota 4750 --cpuset-cpus 0,1,2,3,4,5"
    expect=5
    check
    input="--cpu-quota 4750 --cpuset-cpus 0,1,2,3,4,5"
    expect=1
    check
    input="--cpu-period 0 --cpu-quota 4750 --cpuset-cpus 0,1,2,3,4,5"
    expect=1
    check
    input=""
    expect=8
    check
    input="--cpu-period 1000 --cpu-quota 4750"
    expect=5
    check
    input="--cpuset-cpus 0,1,3,5" 
    expect=4
    check
    input="--cpuset-cpus 0,1"
    expect=2
    check
    input="--cpuset-cpus 0"
    expect=1
    check
    input="--cpuset-cpus 1,2,3"
    expect=3
    check
    input="--cpu-period 1000 --cpu-quota 4750 --cpuset-cpus 0,1,3"
    expect=3
    check
    input="--cpu-period 1000 --cpu-quota 4750 --cpuset-cpus 0,1,3,4,5,6"
    expect=5
    check
    input="--cpu-period 1000 --cpuset-cpus 0,1,3,4,5,6"
    expect=6
    check
    input="--cpuset-cpus 0,1,3,4,5,6"
    expect=6
    check
    input="--cpu-quota 3333 --cpuset-cpus 0,1,3,4,5,6"
    expect=1
    check
    input="--cpu-period 1000 --cpuset-cpus 0,1,3,4,5,6"
    expect=6
    check
    input="--cpu-period 1000"
    expect=8
    check
    input="--cpu-period 1000 --cpu-quota 3333 --cpuset-cpus 0,1,3,4,5,6"
    expect=4
    check
done
