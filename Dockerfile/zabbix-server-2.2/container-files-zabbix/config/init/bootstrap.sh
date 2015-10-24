#!/bin/sh
set -eu
export TERM=xterm
# Bash Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
white=`tput setaf 7`
bold=`tput bold`
reset=`tput sgr0`
separator=$(echo && printf '=%.0s' {1..100} && echo)
# Logging Finctions
log() {
  if [[ "$@" ]]; then echo "${bold}${green}[LOG `date +'%T'`]${reset} $@";
  else echo; fi
}
warning() {
  echo "${bold}${yellow}[WARNING `date +'%T'`]${reset} ${yellow}$@${reset}";
}
error() {
  echo "${bold}${red}[ERROR `date +'%T'`]${reset} ${red}$@${reset}";
}
create_db() {
  mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_ADDR} -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8;"
  mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_ADDR} -e "GRANT ALL ON zabbix.* TO '${DB_USER}'@'%' identified by '${DB_PASS}';"
  mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_ADDR} -e "flush privileges;"
}
import_zabbix_db() {
  mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_ADDR} -D zabbix < ${ZABBIX_SQL_DIR}/schema.sql
  mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_ADDR} -D zabbix < ${ZABBIX_SQL_DIR}/images.sql
  mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_ADDR} -D zabbix < ${ZABBIX_SQL_DIR}/data.sql
}
logging() {
  mkdir -p /var/log/zabbix
  chmod 777 /var/log/zabbix
  touch /var/log/zabbix/zabbix_server.log /var/log/zabbix/zabbix_agentd.log
  chmod 777 /var/log/zabbix/zabbix_server.log /var/log/zabbix/zabbix_agentd.log
}
system_pids() {
  touch /var/run/zabbix_server.pid /var/run/zabbix_agentd.pid /var/run/zabbix_java.pid
  chmod 777 /var/run/zabbix_server.pid /var/run/zabbix_agentd.pid /var/run/zabbix_java.pid
}
fix_permissions() {
  getent group zabbix || groupadd zabbix
  getent passwd zabbix || useradd -g zabbix -M zabbix
  chown -R zabbix:zabbix /usr/local/etc/
  chown -R zabbix:zabbix /usr/local/src/zabbix/
  mkdir -p /usr/local/src/zabbix/frontends/php/conf/
  chmod 777 /usr/local/src/zabbix/frontends/php/conf/
  chmod u+s `which ping`
}
update_config() {
  sed -i 's/DEBUG_LEVEL/'${DEBUG_LEVEL}'/g' /usr/local/etc/zabbix_server.conf
  sed -i 's/DB_ADDR/'${DB_ADDR}'/g' /usr/local/etc/zabbix_server.conf
  sed -i 's/DB_USER/'${DB_USER}'/g' /usr/local/etc/zabbix_server.conf
  sed -i 's/DB_PASS/'${DB_PASS}'/g' /usr/local/etc/zabbix_server.conf
  sed -i 's/DB_PORT/'${DB_PORT}'/g' /usr/local/etc/zabbix_server.conf
  sed -i 's/DB_NAME/'${DB_NAME}'/g' /usr/local/etc/zabbix_server.conf

  #cp /usr/local/src/zabbix/frontends/php/zabbix.conf.php /usr/local/src/zabbix/frontends/php/conf/
  sed -i 's/DB_ADDR/'${DB_ADDR}'/g' /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  sed -i 's/DB_USER/'${DB_USER}'/g' /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  sed -i 's/DB_PASS/'${DB_PASS}'/g' /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  sed -i 's/DB_PORT/'${DB_PORT}'/g' /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  sed -i 's/DB_NAME/'${DB_NAME}'/g' /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php

  sed -i 's/PHP_TIMEZONE/'${PHP_TIMEZONE}'/g' /etc/php.d/zz-zabbix.ini
}
####################### End of default settings #######################
# Zabbix default sql files 
ZABBIX_SQL_DIR="/usr/local/src/zabbix/database/mysql"
log "Preparing server configuration"
update_config
log "Config updated."
log "Enabling Logging and pid management."
logging
system_pids
fix_permissions
log "Done"
log "Checking if Database exists or fresh install"
if ! mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_ADDRESS} -e "use zabbix;"; then
  warning "Zabbix DB doesn't exists. Installing and importing default settings"
  log `create_db`
  log "Database and user created. Importing Default SQL"
  log `import_zabbix_db`
  log "Import Finished. Starting"
else 
  log "Zabbix DB Exists. Starting server."
fi
# TODO wait for zabbix-server start
#python /config/pyzabbix.py 2>/dev/null
zabbix_agentd -c /usr/local/etc/zabbix_agentd.conf
