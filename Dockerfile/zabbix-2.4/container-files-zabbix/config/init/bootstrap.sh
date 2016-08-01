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

# Logging functions
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
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "CREATE DATABASE IF NOT EXISTS ${ZS_DBName} CHARACTER SET utf8;"
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "GRANT ALL ON ${ZS_DBName}.* TO '${ZS_DBUser}'@'%' identified by '${ZS_DBPassword}';"
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "flush privileges;"
}
import_zabbix_db() {
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName} < ${ZABBIX_SQL_DIR}/schema.sql
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName} < ${ZABBIX_SQL_DIR}/images.sql
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName} < ${ZABBIX_SQL_DIR}/data.sql
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
  chmod u+s /usr/bin/ping
  chown root:zabbix /usr/sbin/fping
  chown root:zabbix /usr/sbin/fping6
  chmod 4710 /usr/sbin/fping
  chmod 4710 /usr/sbin/fping6
}
update_config() {
  # ^ZS_: /usr/local/etc/zabbix_server.conf
  for i in $( set -o posix ; set | grep ^ZS_ | grep -v ^ZS_Include | grep -v ^ZS_LoadModule | grep -v ^ZS_SourceIP | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#=${reg}\$#=${val}#g" /usr/local/etc/zabbix_server.conf
    sed -i "s#${reg}#${val}#g" /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  done
  if [ "$ZS_SourceIP" != "" ]; then
    echo SourceIP=${ZS_SourceIP} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_Include" != "" ]; then
    echo Include=${ZS_Include} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_LoadModule" != "" ]; then
    echo LoadModule=${ZS_LoadModule} >> /usr/local/etc/zabbix_server.conf
  fi

  # ^ZW_: /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  export ZW_ZBX_SERVER_NAME_e=$(echo ${ZW_ZBX_SERVER_NAME} | sed -e 's/ /\\\ /g')
  sed -i "s#ZW_ZBX_SERVER_NAME#${ZW_ZBX_SERVER_NAME_e}#g" /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  unset ZW_ZBX_SERVER_NAME_e
  for i in $( set -o posix ; set | grep ^ZW_ | grep -v ^ZW_ZBX_SERVER_NAME | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#${reg}#${val}#g" /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  done

  # ^PHP_: /etc/php.d/zz-zabbix.ini
  for i in $( set -o posix ; set | grep ^PHP_ | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#${reg}\$#${val}#g" /etc/php.d/zz-zabbix.ini
  done

  if [ -f /etc/custom-config/php-zabbix.ini ]; then
    cp -f /etc/custom-config/php-zabbix.ini /etc/php.d/zz-zabbix.ini
  fi
  if [ -f /etc/custom-config/zabbix_server.conf ]; then
    cp -f /etc/custom-config/zabbix_server.conf /usr/local/etc/zabbix_server.conf
  fi
}
####################### End of default settings #######################
# Zabbix default sql files
ZABBIX_SQL_DIR="/usr/local/src/zabbix/database/mysql"
# load DB config from custom config file if exist
if [ -f /etc/custom-config/zabbix_server.conf ]; then
  FZS_DBPassword=$(grep ^DBPassword= /etc/custom-config/zabbix_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBPassword" ]; then
    export ZS_DBPassword=$FZS_DBPassword
  fi
  FZS_DBUser=$(grep ^DBUser= /etc/custom-config/zabbix_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBUser" ]; then
    export ZS_DBUser=$FZS_DBUser
  fi
  FZS_DBHost=$(grep ^DBHost= /etc/custom-config/zabbix_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBHost" ]; then
    export ZS_DBHost=$FZS_DBHost
  fi
  FZS_DBPort=$(grep ^DBPort= /etc/custom-config/zabbix_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBPort" ]; then
    export ZS_DBPort=$FZS_DBPort
  fi
  FZS_DBName=$(grep ^ZS_DBName= /etc/custom-config/zabbix_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBName" ]; then
    export ZS_DBName=$FZS_DBName
  fi
fi
log "Preparing server configuration"
update_config
log "Config updated."
log "Enabling logging and pid management"
logging
system_pids
fix_permissions
log "Done"

if $ZS_enabled; then
  # wait 120sec for DB server initialization
  retry=24
  log "Waiting for database server"
  until mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "exit" &>/dev/null
  do
    log "Waiting for database server, it's still not available"
    retry=`expr $retry - 1`
    if [ $retry -eq 0 ]; then
      error "Database server is not available!"
      exit 1
    fi
    sleep 5
  done
  log "Database server is available"

  log "Checking if database exists or SQL import is required"
  if ! mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "use ${ZS_DBName};" &>/dev/null; then
    warning "Zabbix database doesn't exist. Installing and importing default settings"
    log `create_db`
    log "Database and user created, importing default SQL"
    log `import_zabbix_db`
    log "Import finished, starting"
  else
    log "Zabbix database exists, starting server"
  fi
else
  # Zabbix server is disabled
  rm -rf /etc/supervisor.d/zabbix-server.conf
fi

if $ZA_enabled; then
  zabbix_agentd -c /usr/local/etc/zabbix_agentd.conf
else
  # Zabbix agent is disabled
  rm -rf /etc/supervisor.d/zabbix-agent.conf
fi

if ! $ZW_enabled; then
  # Zabbix web UI is disabled
  rm -rf /etc/supervisor.d/nginx.conf
  rm -rf /etc/supervisor.d/php-fpm.conf
fi

if ! $SNMPTRAP_enabled; then
  # SNMP trap process is disabled
  rm -rf /etc/supervisor.d/snmptrapd.conf
  rm -rf /etc/logrotate.d/zabbix-traps
fi

# Zabbix version detection
export ZABBIX_VERSION=$(zabbix_server -V | grep Zabbix | awk '{print $3}')

log "Starting Zabbix version $ZABBIX_VERSION"
