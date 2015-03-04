#!/bin/bash

function docker_alias {
	img=$1
	shift
	docker run -it --rm -v $(pwd):/working -w /working $img $@
}

function mysqladmin {
	docker run -it --rm --entrypoint=mysqladmin -v $(pwd):/working -w /working mysql:5.6 $@
}

function mysql {
	docker run -it --rm --entrypoint=mysql -v $(pwd):/working -w /working mysql:5.6 $@
}

function mysqldump {
	docker run -it --rm --entrypoint=mysqldump -v $(pwd):/working -w /working mysql:5.6 $@
}

function subl {
  /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl
}

function php {
  docker_alias php-cli $@
}
function composer {
  docker_alias composer $@
}

function convert {
  docker_alias acleancoder/imagemagick-full convert $@
}

function swift {
  docker_alias swift-client $@
}
function compass {
  docker_alias attensee/compass $@
}

function sass {
  docker run -it --rm -v $(pwd):/working -w /working --entrypoint=sass attensee/compass $@
}

function build_edu {
  sass --update "app/webroot/css/sass":"app/webroot/css/compiled"
  compass compile --output-style compressed --no-line-comments --relative-assets --images-dir app/webroot/img --sass-dir app/webroot/css/compass --css-dir app/webroot/css/compiled
  grunt clean exec:version requirejs exec:symlink_assets
}

function deploy_edu_demo {
  build_edu
  grunt exec:deploy_demo
}

function deploy_edu_prod {
  build_edu
  grunt exec:deploy
}

function etcdapps {
  ETCDCTL_PEERS="http://10.210.132.38:4001" etcdctl $@
}

alias oberd="z oberd && subl ."

alias npmi="npm install --save"
alias npmid="npm install --save-dev"
alias gulp="./node_modules/.bin/gulp"

alias build_custom="compass compile --output-style compressed --no-line-comments --sass-dir form_public/pages/css/custom/v2/scss --css-dir form_public/pages/css/custom/v2 && grunt build:custom --force"
alias build_cpanel="compass compile --sass-dir cpanel_public/pages/css/routed/scss --css-dir cpanel_public/pages/css/routed/compiled"

