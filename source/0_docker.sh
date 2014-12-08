#!/bin/bash

function boot2docker_ip() {
	echo $DOCKER_HOST | cut -f3 -d'/' | cut -f1 -d:
}

function docker-clean {
	docker rm $(docker ps -a -q)
	docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
}