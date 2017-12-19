#!/bin/bash

source ~/.env.local

function dump_schema_to_sql {
  local container=$1
  local schema=$2
  local filename=$3
  mysqldump_container $container --add-drop-table --skip-dump-date --skip-comments \
    --ignore-table=$schema.StudyStartDates -d \
    $schema | awk '{ if ( NR > 1  ) { print } }' | sed 's/ AUTO_INCREMENT=[0-9]*\b//' > $filename
}

function oberd_update_test_schema {
  cd "$OBERD_DIR"
  dump_schema_to_sql oberddocker_mysql_1 medadatonline_demo tests/current_schema.sql
  dump_schema_to_sql oberddocker_mysql_1 demo_InstitutionURS tests/current_institution_schema.sql
}

function oberd_import_test_schema {
  cd "$OBERD_DIR"
  import_database oberddocker_mysql_1 medadatonline_test tests/current_schema.sql
  import_database oberddocker_mysql_1 test_InstitutionFixture tests/current_institution_schema.sql
  import_database oberddocker_mysql_1 OBERDDevice_test tests/current_device_schema.sql
}

function ps_update_test_schema {
  dump_schema_to_sql oberddocker_mysql_1 patientsatisfaction_demo db/current_schema.sql
}

function ps_import_test_schema {
  import_database oberddocker_mysql_1 patientsatisfaction_test db/current_schema.sql
}

function oberd_test {
  docker exec  oberddocker_oberd_1 /bin/bash -c "cd /var/www/tests && php ../vendor/bin/phpunit --testsuite=$1"
}

function oberd_browser {
  docker exec oberddocker_oberd_1 /bin/bash -c 'php -d error_reporting="E_ALL&~E_WARNING&~E_NOTICE&~E_STRICT" tests/lib/phpunit/bin/paratest -p 2 -f --phpunit=tests/lib/phpunit/bin/phpunit -c tests/browser/phpunit.xml --testsuite="browser"'
}
function oberd_browser_single {
  docker exec oberddocker_oberd_1 /bin/bash -c 'php -d error_reporting="E_ALL&~E_WARNING&~E_NOTICE&~E_STRICT" tests/lib/phpunit/bin/phpunit -c tests/browser/phpunit.xml --testsuite="browser"'
}

function odc {
  docker_dir="$(dirname $OBERD_DIR)/docker"
  docker-compose -f "$docker_dir/docker-compose.yml" $@
}

function odcrs {
  main=${1:-oberd}
  docker_config="$(dirname $OBERD_DIR)/docker/docker-compose.yml"
  docker-compose -f "$docker_config" kill $main
  docker-compose -f "$docker_config" rm -f $main
  docker-compose -f "$docker_config" up -d $main
}