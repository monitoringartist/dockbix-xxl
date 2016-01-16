#!/bin/sh

#########################################################
# Config DB
#########################################################
function config_db() {
  # ^DB_: /etc/my.cnf.d/tuning.cnf
  for i in $( set -o posix ; set | grep ^DB_ | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#${reg}\$#${val}#g" /etc/my.cnf.d/tuning.cnf
  done
  
  if [ -f /etc/custom-config/mariadb-tuning.cnf ]; then
    cp -f /etc/custom-config/mariadb-tuning.cnf /etc/my.cnf.d/tuning.cnf
  fi
}

#########################################################
# Check in the loop (every 1s) if the database backend
# service is already available for connections.
#########################################################
function wait_for_db() {
  set +e
  
  echo "Waiting for DB service..."
  while true; do
    if grep "ready for connections" $ERROR_LOG; then
      break;
    else
      echo "Still waiting for DB service..." && sleep 1
    fi
  done
  
  set -e
}

#########################################################
# Check in the loop (every 1s) if the database backend
# service is already available for connections.
#########################################################
function terminate_db() {
  local pid=$(cat $VOLUME_HOME/mysql.pid)
  echo "Caught SIGTERM signal, shutting down DB..."
  kill -TERM $pid
  
  while true; do
    if tail $ERROR_LOG | grep -s -E "mysqld .+? ended" $ERROR_LOG; then break; else sleep 0.5; fi
  done
}

#########################################################
# Cals `mysql_install_db` if empty volume is detected.
# Globals:
#   $VOLUME_HOME
#   $ERROR_LOG
#########################################################
function install_db() {
  if [ ! -d $VOLUME_HOME/mysql ]; then
    echo "=> An empty/uninitialized MariaDB volume is detected in $VOLUME_HOME"
    echo "=> Installing MariaDB..."
    mysql_install_db --user=mysql > /dev/null 2>&1
    echo "=> Installing MariaDB... Done!"
  else
    echo "=> Using an existing volume of MariaDB."
  fi
  
  # Move previous error log (which might be there from previously running container
  # to different location. We do that to have error log from the currently running
  # container only.
  if [ -f $ERROR_LOG ]; then
    echo "----------------- Previous error log -----------------"
    tail -n 20 $ERROR_LOG
    echo "----------------- Previous error log ends -----------------" && echo
    mv -f $ERROR_LOG "${ERROR_LOG}.old";
  fi

  touch $ERROR_LOG && chown mysql $ERROR_LOG
}

#########################################################
# Check in the loop (every 1s) if the database backend
# service is already available for connections.
# Globals:
#   $MARIADB_USER
#   $MARIADB_PASS
#########################################################
function create_admin_user() {
  echo "Creating DB admin user..." && echo
  local users=$(mysql -s -e "SELECT count(User) FROM mysql.user WHERE User='$MARIADB_USER'")
  if [[ $users == 0 ]]; then
    echo "=> Creating MariaDB user '$MARIADB_USER' with '$MARIADB_PASS' password."
    mysql -uroot -e "CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASS'"
  else
    echo "=> User '$MARIADB_USER' exists, updating its password to '$MARIADB_PASS'"
    mysql -uroot -e "SET PASSWORD FOR '$MARIADB_USER'@'%' = PASSWORD('$MARIADB_PASS')"
  fi;
  
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_USER'@'%' WITH GRANT OPTION"

  echo "========================================================================"
  echo "    You can now connect to this MariaDB Server using:                   "
  echo "    mysql -u$MARIADB_USER -p$MARIADB_PASS -h<host>                      "
  echo "                                                                        "
  echo "    For security reasons, you might want to change the above password.  "
  echo "    The 'root' user has no password but only allows local connections   "
  echo "========================================================================"
}

function show_db_status() {
  echo "Showing DB status..." && echo
  mysql -uroot -e "status"
}

function secure_and_tidy_db() {
  echo "Securing and tidying DB..."
  mysql -uroot -e "DROP DATABASE IF EXISTS test"
  mysql -uroot -e "DELETE FROM mysql.user where User = ''"
  
  # Remove warning about users with hostnames (as DB is configured with skip_name_resolve)
  mysql -uroot -e "DELETE FROM mysql.user where User = 'root' AND Host NOT IN ('127.0.0.1','::1')"
  mysql -uroot -e "DELETE FROM mysql.proxies_priv where User = 'root' AND Host NOT IN ('127.0.0.1','::1')"
  echo "Securing and tidying DB... Done!"
}
