#!/bin/bash

function docker_alias {
	img=$1
	shift
	docker run -it --rm -v "$(pwd)":/working -w /working $img $@
}

function subl {
  /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl
}

function vsc {
  /Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron
}

function php5-composer {
  docker run -it --rm --privileged --memory "4g" -v ~/.dotfiles/caches/composer:/composer_cache -v ~/.dotfiles/caches/composer_home:/composer_home -v $(pwd):/working -w /working -e COMPOSER_CACHE_DIR=/composer_cache -e COMPOSER_HOME=/composer_home oberd/composer "$@"
}

function php7-composer {
  docker run -it --rm --privileged --memory "4g" -v ~/.dotfiles/caches/composer:/composer_cache -v ~/.dotfiles/caches/composer_home:/composer_home -v $(pwd):/working -w /working -e COMPOSER_CACHE_DIR=/composer_cache -e COMPOSER_HOME=/composer_home oberd/php7-composer "$@"
}

function composer {
  php7-composer "$@"
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

function edu_sass {
  sass --update "app/webroot/css/sass":"app/webroot/css/compiled"
  compass compile --output-style compressed --no-line-comments --relative-assets --images-dir app/webroot/img --sass-dir app/webroot/css/compass --css-dir app/webroot/css/compiled
}

function build_edu {
  sass --update "app/webroot/css/sass":"app/webroot/css/compiled"
  compass compile --output-style compressed --no-line-comments --relative-assets --images-dir app/webroot/img --sass-dir app/webroot/css/compass --css-dir app/webroot/css/compiled
  grunt clean exec:version requirejs exec:symlink_assets
}

function deploy_edu_demo {
  build_edu
  grunt exec:deploy_demo --force
}

function deploy_edu_prod {
  build_edu
  grunt exec:deploy --force
}

function etcdapps {
  ETCDCTL_PEERS="http://10.210.132.38:4001" etcdctl $@
}

# function oberd_migrate {
#   docker exec -it oberddocker_oberd_1 /bin/bash -c "SILENT=true php /var/www/database/migrations/migrate.php "$@""
# }
alias oberd_migrate='docker exec -it oberddocker_oberd_1 /bin/bash -c "SILENT=true php /var/www/database/migrations/migrate.php"'

function copy_ssh {
  mkdir ssh
  cp ~/.ssh/id_ursadmin ssh/id_rsa
  cp ~/.ssh/id_ursadmin.pub ssh/id_rsa.pub
  cp ~/.ssh/known_hosts ssh/known_hosts
}

function de {
  echo "Linking docker to oberd environment"
  export VAGRANT_BOOT2DOCKER_IP="$(docker-machine ip oberd)"
  export DOCKER_HOST_IP="$(docker-machine ip oberd)"
  export ETCDCTL_PEERS="http://$(docker-machine ip oberd):5001"
  eval $(docker-machine env oberd)
}

function rs {
  main=${1:-web}
  docker-compose kill $main && docker-compose rm -f $main && docker-compose up -d $main
}

function de_carina {
  CLUSTER=${1:-boatie}
  if [ ! -d "/tmp/$CLUSTER" ]; then
    carina credentials --path "/tmp/$CLUSTER" $CLUSTER
  fi
  source "/tmp/$CLUSTER/docker.env"
}

alias wifi="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

alias start_redis="docker run -d -p 6379:6379 --name=redis redis"

alias oberd="z oberd && subl ."

alias npmi="npm install --save"
alias npmid="npm install --save-dev"
alias gulp="./node_modules/.bin/gulp"

alias build_custom_css="compass compile --output-style compressed --no-line-comments --sass-dir form_public/pages/css/custom/v2/scss --css-dir form_public/pages/css/custom/v2"
alias build_custom="compass compile --output-style compressed --no-line-comments --sass-dir form_public/pages/css/custom/v2/scss --css-dir form_public/pages/css/custom/v2 && grunt build:custom --force"
alias build_cpanel="compass compile --sass-dir cpanel_public/pages/css/routed/scss --css-dir cpanel_public/pages/css/routed/compiled"
alias watch_cpanel="compass watch --sass-dir cpanel_public/pages/css/routed/scss --css-dir cpanel_public/pages/css/routed/compiled"

alias oberd_bash="docker exec -it oberd_web_1 /bin/bash"

alias npm_patch='VERSION=$(npm version patch) && npm publish && git push origin $VERSION'

alias phplint="docker run --rm -v $PWD:/app 269976911723.dkr.ecr.us-west-2.amazonaws.com/oberd/analyzers-php"
