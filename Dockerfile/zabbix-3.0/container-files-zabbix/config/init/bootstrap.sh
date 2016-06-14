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
  chown root:$ZS_User /usr/sbin/fping
  chown root:$ZS_User /usr/sbin/fping6
  chmod 4710 /usr/sbin/fping
  chmod 4710 /usr/sbin/fping6
}
xxl_config() {
  # disable/enable XXL features
  if ! $XXL_searcher; then
    sed -i "s#['url' => 'searcher.php','label' => _('Searcher'),],#g" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/searcher/ /usr/local/src/zabbix/frontends/php/searcher.php
  fi
  if ! $XXL_zapix; then
    sed -i "s#['url' => 'zapix.php','label' => _('Zapix'),],#g" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/zapix/ /usr/local/src/zabbix/frontends/php/zapix.php
  fi
  if ! $XXL_grapher; then
    sed -i "s#['url' => 'grapher.php','label' => _('Grapher'),],#g" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/grapher/ /usr/local/src/zabbix/frontends/php/grapher.php
  fi
}
update_config() {
  # ^ZS_: /usr/local/etc/zabbix_server.conf
  for i in $( set -o posix ; set | grep ^ZS_ | grep -v ^ZS_Include | grep -v ^ZS_LoadModule | grep -v ^ZS_SourceIP | grep -v ^ZS_TLS | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#=${reg}\$#=${val}#g" /usr/local/etc/zabbix_server.conf
    sed -i "s#${reg}#${val}#g" /usr/local/src/zabbix/frontends/php/conf/zabbix.conf.php
  done
  if [ "$ZS_SourceIP" != "" ]; then
    sed -i -e "\|^SourceIP=|d" /usr/local/etc/zabbix_server.conf
    echo SourceIP=${ZS_SourceIP} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_Include" != "" ]; then
    sed -i -e "\|^Include=|d" /usr/local/etc/zabbix_server.conf
    echo Include=${ZS_Include} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_LoadModule" != "" ]; then
    sed -i -e "\|^LoadModule=|d" /usr/local/etc/zabbix_server.conf
    echo LoadModule=${ZS_LoadModule} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_TLSCAFile" != "" ]; then
    sed -i -e "\|^TLSCAFile=|d" /usr/local/etc/zabbix_server.conf
    echo TLSCAFile=${ZS_TLSCAFile} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_TLSCRLFile" != "" ]; then
    sed -i -e "\|^TLSCRLFile=|d" /usr/local/etc/zabbix_server.conf
    echo TLSCRLFile=${ZS_TLSCRLFile} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_TLSCertFile" != "" ]; then
    sed -i -e "\|^TLSCertFile=|d" /usr/local/etc/zabbix_server.conf
    echo TLSCertFile=${ZS_TLSCertFile} >> /usr/local/etc/zabbix_server.conf
  fi
  if [ "$ZS_TLSCAFile" != "" ]; then
    sed -i -e "\|^TLSKeyFile=|d" /usr/local/etc/zabbix_server.conf
    echo TLSKeyFile=${ZS_TLSKeyFile} >> /usr/local/etc/zabbix_server.conf
  fi

  # ^ZA_: /usr/local/etc/zabbix_agentd.conf
  export ZA_Hostname_e=$(echo ${ZA_Hostname} | sed -e 's/ /\\\ /g')
  sed -i "s#ZA_Hostname#${ZA_Hostname_e}#g" /usr/local/etc/zabbix_agentd.conf
  unset ZA_Hostname_e
  for i in $( set -o posix ; set | grep ^ZA_ | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#=${reg}\$#=${val}#g" /usr/local/etc/zabbix_agentd.conf
  done
  if [ "$ZA_TLSCAFile" != "" ]; then
    sed -i -e "\|^TLSCAFile=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSCAFile=${ZA_TLSCAFile} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_TLSCRLFile" != "" ]; then
    sed -i -e "\|^TLSCRLFile=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSCRLFile=${ZA_TLSCRLFile} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_TLSServerCertIssuer" != "" ]; then
    sed -i -e "\|^TLSServerCertIssuer=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSServerCertIssuer=${ZA_TLSServerCertIssuer} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_TLSServerCertSubject" != "" ]; then
    sed -i -e "\|^TLSServerCertSubject=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSServerCertSubject=${ZA_TLSServerCertSubject} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_TLSCertFile" != "" ]; then
    sed -i -e "\|^TLSCertFile=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSCertFile=${ZA_TLSCertFile} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_TLSKeyFile" != "" ]; then
    sed -i -e "\|^TLSKeyFile=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSKeyFile=${ZA_TLSKeyFile} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_TLSPSKIdentity" != "" ]; then
    sed -i -e "\|^TLSPSKIdentity=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSPSKIdentity=${ZA_TLSPSKIdentity} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_TLSPSKFile" != "" ]; then
    sed -i -e "\|^TLSPSKFile=|d" /usr/local/etc/zabbix_agentd.conf
    echo TLSPSKFile=${ZA_TLSPSKFile} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_SourceIP" != "" ]; then
    sed -i -e "\|^SourceIP=|d" /usr/local/etc/zabbix_agentd.conf
    echo SourceIP=${ZA_SourceIP} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_LoadModulePath" != "" ]; then
    sed -i -e "\|^LoadModulePath=|d" /usr/local/etc/zabbix_agentd.conf
    echo LoadModulePath=${ZA_LoadModulePath} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_UserParameter" != "" ]; then
    sed -i -e "\|^UserParameter=|d" /usr/local/etc/zabbix_agentd.conf
    echo UserParameter=${ZA_UserParameter} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_HostMetadata" != "" ]; then
    sed -i -e "\|^HostMetadata=|d" /usr/local/etc/zabbix_agentd.conf
    echo HostMetadata=${ZA_HostMetadata} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_Include" != "" ]; then
    sed -i -e "\|^Include=|d" /usr/local/etc/zabbix_agentd.conf
    echo Include=${ZA_Include} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_Hostname" != "" ]; then
    sed -i -e "\|^Hostname=|d" /usr/local/etc/zabbix_agentd.conf
    echo Hostname=${ZA_Hostname} >> /usr/local/etc/zabbix_agentd.conf
  fi
  if [ "$ZA_HostnameItem" != "" ]; then
    sed -i -e "\|^HostnameItem=|d" /usr/local/etc/zabbix_agentd.conf
    echo HostnameItem=${ZA_HostnameItem} >> /usr/local/etc/zabbix_agentd.conf
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
  FZS_DBName=$(grep ^DBName= /etc/custom-config/zabbix_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBName" ]; then
    export ZS_DBName=$FZS_DBName
  fi
fi
log "Preparing server configuration"
update_config
xxl_config
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
  mv /usr/local/etc/logback.xml /usr/local/sbin/zabbix_java/lib/
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
    for i in $( set -o posix ; set | grep ^ZP_ | grep -v '^ZP_enabled' | sort -rn ); do
      reg=$(echo ${i} | awk -F'=' '{print $1}' | sed 's|^ZP_||')
      val=$(echo ${i} | awk -F'=' '{print $2}')
      echo  "${reg}=${val}" >> /usr/local/etc/zabbix_proxy.conf
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