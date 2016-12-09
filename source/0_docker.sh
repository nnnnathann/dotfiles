#!/bin/bash

function boot2docker_ip() {
	echo $DOCKER_HOST | cut -f3 -d'/' | cut -f1 -d:
}

function docker-clean {
	docker rm `docker ps -a | grep Exited | awk '{print $1 }'`
	docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
}

function docker-tunnel {
  pushd "$VAGRANT_BOOT2DOCKER" > /dev/null
  vagrant ssh -c 'ssh -i ~/.ssh/id_ursreg root@10.210.69.43 -f -N -L 5000:localhost:5000'
  popd
}