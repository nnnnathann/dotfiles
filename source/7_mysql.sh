#!/bin/bash

SCHEMA="medadatonline_demo"
PREFIX="demo_"

source ~/.env.local

REMOTE_DUMPS="/home/$OBERD_DB_SSH_USER/data_export/dumps"
LOCAL_DUMPS="$HOME/.dotfiles/caches/mysql"

function mysqldump_container {
  container=$1
  shift
  docker run -it --rm --link=$container:db -v $(pwd):/working -w /working oberd/mysql-dump $@
}

# Usage:
#   mysql_import [container_name] [database_schema] [file]

function mysql_import {
  container=$1
  schema=$2
  file=$3
  docker run -it --rm --link=$container:db -v "$file":/tmp.sql oberd/mysql-console $schema "< /tmp.sql"
}

function sync_database {
  # Export the database on remote
  container=$1
  schema=$2
  echo "Syncing remote $schema to container $container"
  ssh $OBERD_DB_SSH_USER@$OBERD_DB_SERVER "mysqldump --lock-tables=false -u $OBERD_DB_USER --password='$OBERD_DB_PASS' $schema > $REMOTE_DUMPS/$schema.sql"
  # Copy the file down to local
  rsync -uavz $OBERD_DB_SSH_USER@$OBERD_DB_SERVER:"$REMOTE_DUMPS/$schema.sql" $LOCAL_DUMPS > /dev/null 2>&1
  import_database "$container" "$schema" "$LOCAL_DUMPS/$schema.sql"
}

function mysql_drop {
  container=$1
  schema=$2
  echo "Dropping $schema from $container"
  docker run -it --rm --link=$container:db oberd/mysql-console mysqladmin -f drop $schema > /dev/null 2>&1
}

function mysql_create {
  container=$1
  schema=$2
  echo "Creating $schema in $container"
  docker run -it --rm --link=$container:db oberd/mysql-console mysqladmin -f create $schema > /dev/null 2>&1
}

function import_database {
  container=$1
  schema=$2
  file=$3
  mysql_drop $container $schema
  mysql_create $container $schema
  db_file=$LOCAL_DUMPS/$schema.sql
  if [ ! -z "$file" ]; then
    db_file=$(abs $file)
  fi
  echo "Importing file: $db_file into container $container $schema"
  mysql_import $container $schema $db_file
}

function import_sql {
  local filename=$(basename "$1")
  local extension="${filename##*.}"
  filename="${filename%.*}"
  mysqladmin -f -u$MYSQL_USER --password=$MYSQL_PASS --host $MYSQL_HOST drop $1 
}

function sync_databases {
  container=$1
  shift
  for DB in "$@"; do
    sync_database $container $DB
  done
}

function sync_demo {
  ssh $OBERD_DB_SSH_USER@$OBERD_DB_SERVER "mkdir -p $REMOTE_DUMPS > /dev/null 2>&1"
  mkdir -p $LOCAL_DUMPS > /dev/null 2>&1
  
  # # # Sync up the main schema
  # sync_database oberd_db_1 $SCHEMA

  # # # Sync up all other databases prefixed with the prefix
  PREFIXED_DBS=`ssh $OBERD_DB_SSH_USER@$OBERD_DB_SERVER "mysql -u $OBERD_DB_USER --password='$OBERD_DB_PASS' -e 'SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME LIKE \"$PREFIX%\"'" | grep ^$PREFIX | xargs`
  sync_databases oberd_db_1 $PREFIXED_DBS
}

function sync_satisfaction {
  sync_database 'patientsatisfaction_demo'
}
function sync_compliance {
  sync_database 'QuestionnaireCompliance_demo'
}
function sync_edu {
  sync_database "oberd_db_1" "riedu"
  sync_database "oberd_db_1" "edu_prod"
}