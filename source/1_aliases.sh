#!/bin/bash

alias mysqladmin="docker run -it --rm --entrypoint=mysqladmin mysql:5.6"
alias mysql="docker run -it --rm --entrypoint=mysql mysql:5.6"

function composer {
	docker run -it --rm -v $(pwd):/working composer "$@"
}

alias oberd="z oberd && subl ."