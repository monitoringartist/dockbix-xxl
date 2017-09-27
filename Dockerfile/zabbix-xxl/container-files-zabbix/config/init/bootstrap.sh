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
  else echo -n; fi
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
create_proxy_db() {
  mysql -u ${ZP_DBUser} -p${ZP_DBPassword} -h ${ZP_DBHost} -P ${ZP_DBPort} -e "CREATE DATABASE IF NOT EXISTS ${ZP_DBName} CHARACTER SET utf8;"
  mysql -u ${ZP_DBUser} -p${ZP_DBPassword} -h ${ZP_DBHost} -P ${ZP_DBPort} -e "GRANT ALL ON ${ZP_DBName}.* TO '${ZP_DBUser}'@'%' identified by '${ZP_DBPassword}';"
  mysql -u ${ZP_DBUser} -p${ZP_DBPassword} -h ${ZP_DBHost} -P ${ZP_DBPort} -e "flush privileges;"
}
import_zabbix_proxy_db() {
  mysql -u ${ZP_DBUser} -p${ZP_DBPassword} -h ${ZP_DBHost} -P ${ZP_DBPort} -D ${ZP_DBName} < ${ZABBIX_SQL_DIR}/schema.sql
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
  chown -R $ZS_User:$ZS_User /usr/local/etc/
  chown -R $ZS_User:$ZS_User /usr/local/src/zabbix/
  mkdir -p /usr/local/src/zabbix/frontends/php/conf/
  chmod 777 /usr/local/src/zabbix/frontends/php/conf/
  chmod u+s /usr/bin/ping
  chmod 4711 /usr/sbin/fping
  chmod 4711 /usr/sbin/fping6
}
update_config() {
  # ^ZS_: /usr/local/etc/zabbix_server.conf
  > /usr/local/etc/zabbix_server.conf
  for i in $( printenv | grep ^ZS_ | grep -v '^ZS_enabled' | awk -F'=' '{print $1}' | sort -rn ); do
    reg=$(echo ${i} | sed 's|^ZS_||' | sed -E "s/_[0-9]+$//")
    val=$(echo ${!i})
    echo "${reg}=${val}" >> /usr/local/etc/zabbix_server.conf
    sed -i "s#ZS_${reg}#${val}#g" /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  done

  # ^ZA_: /usr/local/etc/zabbix_agentd.conf
  export ZA_Hostname_e=$(echo ${ZA_Hostname} | sed -e 's/ /\\\ /g')
  sed -i "s#ZA_Hostname#${ZA_Hostname_e}#g" /usr/local/etc/zabbix_agentd.conf
  unset ZA_Hostname_e
  > /usr/local/etc/zabbix_agentd.conf
  for i in $( printenv | grep ^ZA_ | grep -v '^ZA_enabled' |  awk -F'=' '{print $1}' | sort -rn ); do
    reg=$(echo ${i} | sed 's|^ZA_||' | sed -E "s/_[0-9]+$//")
    val=$(echo ${!i})
    echo "${reg}=${val}" >> /usr/local/etc/zabbix_agentd.conf
  done

  # ^ZW_: /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  export ZW_ZBX_SERVER_NAME_e=$(echo ${ZW_ZBX_SERVER_NAME} | sed -e 's/ /\\\ /g')
  sed -i "s#ZW_ZBX_SERVER_NAME#${ZW_ZBX_SERVER_NAME_e}#g" /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  unset ZW_ZBX_SERVER_NAME_e
  for i in $( printenv | grep ^ZW_ | grep -v '^ZW_ZBX_SERVER_NAME' |  awk -F'=' '{print $1}' | sort -rn ); do
    reg=$(echo ${i} | sed 's|^ZW_||')
    val=$(echo ${!i})
    sed -i "s#ZW_${reg}#${val}#g" /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  done

  # ^PHP_: /etc/php.d/zz-zabbix.ini
  for i in $( printenv | grep ^PHP_ | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#${reg}\$#${val}#g" /etc/php.d/zz-zabbix.ini
  done

  ZBX_GRAPH_FONT_NAME=${ZBX_GRAPH_FONT_NAME:-DejaVuSans}
  if [ $ZBX_GRAPH_FONT_NAME == "ipagp" ]; then
    sed -i "/ZBX_GRAPH_FONT_NAME/c\define('ZBX_GRAPH_FONT_NAME','ipagp');" /usr/local/src/zabbix/frontends/php/include/defines.inc.php
  fi

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
  FZS_DBName=$(grep ^DBName= /etc/custom-config/zabbix_server.conf | awk -F= '{print $2}')
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

if ! $ZA_enabled; then
  # Zabbix agent is disabled
  rm -rf /etc/supervisor.d/zabbix-agent.conf
fi

if ! $ZW_enabled; then
  # Zabbix web UI is disabled
  rm -rf /etc/supervisor.d/nginx.conf
  rm -rf /etc/supervisor.d/php-fpm.conf
fi

if ! $ZJ_enabled; then
  # Zabbix Java Gateway disabled
  rm -rf /etc/supervisor.d/zabbix-java-gateway.conf
else
  rm -rf /usr/local/sbin/zabbix_java/lib/logback.xml
  cp /usr/local/etc/logback.xml /usr/local/sbin/zabbix_java/lib/
  if [ -f /etc/custom-config/logback.xml ]; then
    rm -rf /usr/local/sbin/zabbix_java/lib/logback.xml
    cp /etc/custom-config/logback.xml /usr/local/sbin/zabbix_java/lib/
  else
    sed -i "s#<root level=\"info\">#<root level=\"${ZJ_LogLevel}\">#g" /usr/local/sbin/zabbix_java/lib/logback.xml
  fi
  export ZJ_JarFile=$(find /usr/local/sbin/zabbix_java/ -name 'zabbix-java-gateway*.jar' | awk -F'zabbix_java/bin/' '{print $2}')
  export ZJ_JarFile_android_json=$(find /usr/local/sbin/zabbix_java/ -name 'android-json*.jar' | awk -F'zabbix_java/lib/' '{print $2}')
  export ZJ_JarFile_logback_classic=$(find /usr/local/sbin/zabbix_java/ -name 'logback-classic*.jar' | awk -F'zabbix_java/lib/' '{print $2}')
  export ZJ_JarFile_logback_core=$(find /usr/local/sbin/zabbix_java/ -name 'logback-core*.jar' | awk -F'zabbix_java/lib/' '{print $2}')
  export ZJ_JarFile_slf4j_api=$(find /usr/local/sbin/zabbix_java/ -name 'slf4j-api*.jar' | awk -F'zabbix_java/lib/' '{print $2}')
fi

if ! $ZP_enabled; then
  # Zabbix proxy disabled
  rm -rf /etc/supervisor.d/zabbix-proxy.conf
else
  # Zabbix proxy configuration
  if [ -f /etc/custom-config/zabbix_proxy.conf ]; then
    rm -rf /usr/local/etc/zabbix_proxy.conf
    cp /etc/custom-config/zabbix_proxy.conf /usr/local/etc/
    FZP_DBPassword=$(grep ^DBPassword= /etc/custom-config/zabbix_proxy.conf | awk -F= '{print $2}')
    if [ ! -z "$FZP_DBPassword" ]; then
      export ZP_DBPassword=$FZP_DBPassword
    fi
    FZP_DBUser=$(grep ^DBUser= /etc/custom-config/zabbix_proxy.conf | awk -F= '{print $2}')
    if [ ! -z "$FZP_DBUser" ]; then
      export ZP_DBUser=$FZP_DBUser
    fi
    FZP_DBHost=$(grep ^DBHost= /etc/custom-config/zabbix_proxy.conf | awk -F= '{print $2}')
    if [ ! -z "$FZP_DBHost" ]; then
      export ZP_DBHost=$FZP_DBHost
    fi
    FZP_DBPort=$(grep ^DBPort= /etc/custom-config/zabbix_proxy.conf | awk -F= '{print $2}')
    if [ ! -z "$FZP_DBPort" ]; then
      export ZP_DBPort=$FZP_DBPort
    fi
    FZP_DBName=$(grep ^DBName= /etc/custom-config/zabbix_proxy.conf | awk -F= '{print $2}')
    if [ ! -z "$FZP_DBName" ]; then
      export ZP_DBName=$FZP_DBName
    fi
  else
    > /usr/local/etc/zabbix_proxy.conf
    for i in $( printenv | grep ^ZP_ | grep -v '^ZP_enabled' | awk -F'=' '{print $1}' | sort -rn ); do
      reg=$(echo ${i} | sed 's|^ZP_||' | sed -E "s/_[0-9]+$//")
      val=$(echo ${!i})
      echo "${reg}=${val}" >> /usr/local/etc/zabbix_proxy.conf
    done
  fi
  # wait 120sec for DB server initialization
  retry=24
  log "Waiting for database server"
  until mysql -u ${ZP_DBUser} -p${ZP_DBPassword} -h ${ZP_DBHost} -P ${ZP_DBPort} -e "exit" &>/dev/null
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
  log "Checking if proxy database exists or SQL import is required"
  if ! mysql -u ${ZP_DBUser} -p${ZP_DBPassword} -h ${ZP_DBHost} -P ${ZP_DBPort} -e "use ${ZP_DBName};" &>/dev/null; then
    warning "Zabbix proxy database doesn't exist. Installing and importing default settings"
    log `create_proxy_db`
    log "Proxy database and user created, importing default SQL"
    log `import_zabbix_proxy_db`
    log "Import finished, starting"
  else
    log "Zabbix proxy database exists, starting proxy"
  fi
fi

if ! $SNMPTRAP_enabled; then
  # SNMP trap process is disabled
  rm -rf /etc/supervisor.d/snmptrapd.conf
  rm -rf /etc/logrotate.d/zabbix-traps
fi

# Zabbix version detection
export ZABBIX_VERSION=$(zabbix_server -V | grep Zabbix | awk '{print $3}')

log "Starting Zabbix version $ZABBIX_VERSION"
