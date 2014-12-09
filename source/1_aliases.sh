#!/bin/bash

alias mysqladmin="docker run -it --rm --entrypoint=mysqladmin mysql:5.6"
alias mysql="docker run -it --rm --entrypoint=mysql mysql:5.6"

function docker_alias {
	img=$1
	shift
	docker run -it --rm -v $(pwd):/working $img "$@"
}

alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias oberd="z oberd && subl ."

alias composer="docker_alias composer"
alias node="docker_alias node"
alias npm="docker_alias npm"
alias php="docker_alias php-cli"