#!/bin/bash

function boot2docker_ip() {
	echo $DOCKER_HOST | cut -f3 -d'/' | cut -f1 -d:
}

function docker-clean {
	docker rm $(docker ps -a -q)
	docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
}

function docker-tunnel {
  boot2docker ssh 'echo "10.210.69.43 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBO5V08nAv5KxGABk7Kq6P2q667LwQZu4Ogw1zsaXgCRkHk8eaUwoHKusPj8+ObDAhW6ZesAadwoQ5GhUJJtkyQw=" > /home/docker/.ssh/known_hosts'
  boot2docker ssh "ps -A | grep 'ssh -i' | awk '{print $1}' | xargs kill > /dev/null 2&>1"
  boot2docker ssh 'cat /Users/nathanbleigh/.ssh/id_docker  > ~/.ssh/id_docker && chmod 600 ~/.ssh/id_docker && ssh -i ~/.ssh/id_docker root@10.210.69.43 -L 5000:localhost:5000 -N -f'
}