#!/bin/bash

set -e
set -u
source ./mariadb-functions.sh

# User-provided env variables
MARIADB_USER=${MARIADB_USER:="admin"}
MARIADB_PASS=${MARIADB_PASS:-$(pwgen -s 12 1)}

# Other variables
VOLUME_HOME="/var/lib/mysql"
ERROR_LOG="$VOLUME_HOME/error.log"
MYSQLD_PID_FILE="$VOLUME_HOME/mysql.pid"

# Trap INT and TERM signals to do clean DB shutdown
trap terminate_db SIGINT SIGTERM
config_db
install_db
tail -F $ERROR_LOG & # tail all db logs to stdout 

/usr/bin/mysqld_safe & # Launch DB server in the background
MYSQLD_SAFE_PID=$!

wait_for_db
secure_and_tidy_db
show_db_status
create_admin_user

# Do not exit this script untill mysqld_safe exits gracefully
wait $MYSQLD_SAFE_PID
