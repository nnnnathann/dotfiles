#!/bin/bash

SCHEMA="medadatonline_demo"
PREFIX="demo_"

source ~/.env.local

REMOTE_DUMPS="/home/$OBERD_DB_SSH_USER/data_export/dumps"
LOCAL_DUMPS="$HOME/.dotfiles/caches/mysql"

function mysql_import() {
  docker run -it --rm \
    -v "$2":/tmp.sql \
    -e MYSQL_HOST=$MYSQL_HOST \
    -e MYSQL_USER=$MYSQL_USER \
    -e MYSQL_PASS=$MYSQL_PASS \
    -e SCHEMA=$1 \
    mysql-import
}

function sync_database {
  # Export the database on remote
  echo "Syncing $1"
  ssh $OBERD_DB_SSH_USER@$OBERD_DB_SERVER "mysqldump --lock-tables=false -u $OBERD_DB_USER --password='$OBERD_DB_PASS' $1 > $REMOTE_DUMPS/$1.sql"
  # Copy the file down to local
  rsync -uavz $OBERD_DB_SSH_USER@$OBERD_DB_SERVER:"$REMOTE_DUMPS/$1.sql" $LOCAL_DUMPS > /dev/null 2>&1
  import_database "$1"
}

function mysql_drop {
  mysqladmin -f -u$MYSQL_USER --password=$MYSQL_PASS --host $MYSQL_HOST drop $1 > /dev/null 2>&1
}

function mysql_create {
  mysqladmin -f -u$MYSQL_USER --password=$MYSQL_PASS --host $MYSQL_HOST create $1 > /dev/null 2>&1
}

function import_database {
  mysql_drop $1
  mysql_create $1
  db_file=$LOCAL_DUMPS/$1.sql
  if [ ! -z "$2" ]; then
    db_file=$(abs $2)
  fi
  echo "Importing file: $db_file into $1"
  mysql_import $1 $db_file
}

function import_sql {
  local filename=$(basename "$1")
  local extension="${filename##*.}"
  filename="${filename%.*}"
  mysqladmin -f -u$MYSQL_USER --password=$MYSQL_PASS --host $MYSQL_HOST drop $1 
}

function sync_databases {
  for DB in "$@"; do
    sync_database $DB
  done
}

function sync_demo {
  ssh $OBERD_DB_SSH_USER@$OBERD_DB_SERVER "mkdir -p $REMOTE_DUMPS > /dev/null 2>&1"
  mkdir -p $LOCAL_DUMPS > /dev/null 2>&1
  
  # # # Sync up the main schema
  sync_database $SCHEMA

  # # # Sync up all other databases prefixed with the prefix
  PREFIXED_DBS=`ssh $OBERD_DB_SSH_USER@$OBERD_DB_SERVER "mysql -u $OBERD_DB_USER --password='$OBERD_DB_PASS' -e 'SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME LIKE \"$PREFIX%\"'" | grep ^$PREFIX | xargs`
  sync_databases $PREFIXED_DBS
}

function sync_satisfaction {
  sync_database 'patientsatisfaction_demo'
}
function sync_compliance {
  sync_database 'QuestionnaireCompliance_demo'
}
function sync_edu {
  sync_database "riedu"
}