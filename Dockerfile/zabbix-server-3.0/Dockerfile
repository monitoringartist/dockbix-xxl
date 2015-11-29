FROM centos:centos7
MAINTAINER Jan Garaj info@monitoringartist.com

# ZABBIX_VERSION= trunk tags/2.4.6 branches/dev/ZBXNEXT-1263-1

ENV \
  ZABBIX_VERSION=trunk \
  STATUS_PAGE_ALLOWED_IP=127.0.0.1 \
  JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/bin/java \
  JAVA=/usr/lib/jvm/java-1.8.0-openjdk/bin/java \
  PHP_date_timezone=UTC \
  PHP_max_execution_time=300 \
  PHP_max_input_time=300 \
  PHP_memory_limit=128M \
  PHP_error_reporting=E_ALL \
  ZS_ListenPort=10051 \
  ZS_SourceIP="" \
  ZS_LogFile=/tmp/zabbix_server.log \
  ZS_LogFileSize=10 \
  ZS_DebugLevel=3 \
  ZS_PidFile=/var/run/zabbix_server.pid \
  ZS_DBHost=zabbix.db \
  ZS_DBName=zabbix \
  ZS_DBSchema="" \
  ZS_DBUser=zabbix \
  ZS_DBPassword=zabbix \
  ZS_DBSocket=/tmp/mysql.sock \
  ZS_DBPort=3306 \
  ZS_StartPollers=5 \
  ZS_StartPollersUnreachable=1 \
  ZS_StartTrappers=5 \
  ZS_StartPingers=1 \
  ZS_StartDiscoverers=1 \
  ZS_StartHTTPPollers=1 \
  ZS_StartTimers=1 \
  ZS_JavaGateway=127.0.0.1 \
  ZS_JavaGatewayPort=10052 \
  ZS_StartJavaPollers=0 \
  ZS_StartVMwareCollectors=0 \
  ZS_VMwareFrequency=60 \
  ZS_VMwarePerfFrequency=60 \
  ZS_VMwareCacheSize=8M \
  ZS_VMwareTimeout=10 \
  ZS_SNMPTrapperFile=/tmp/zabbix_traps.tmp \
  ZS_StartSNMPTrapper=0 \
  ZS_ListenIP=0.0.0.0 \
  ZS_HousekeepingFrequency=1 \
  ZS_MaxHousekeeperDelete=500 \
  ZS_SenderFrequency=30 \
  ZS_CacheSize=8M \
  ZS_CacheUpdateFrequency=60 \
  ZS_StartDBSyncers=4 \
  ZS_HistoryCacheSize=8M \
  ZS_TrendCacheSize=4M \
  ZS_HistoryTextCacheSize=16M \
  ZS_ValueCacheSize=8M \
  ZS_Timeout=3 \
  ZS_TrapperTimeout=300 \
  ZS_UnreachablePeriod=45 \
  ZS_UnavailableDelay=60 \
  ZS_UnreachableDelay=15 \
  ZS_AlertScriptsPath=/usr/local/share/zabbix/alertscripts \
  ZS_ExternalScripts=/usr/local/share/zabbix/externalscripts \
  ZS_FpingLocation=/usr/sbin/fping \
  ZS_Fping6Location=/usr/sbin/fping6 \
  ZS_SSHKeyLocation="" \
  ZS_LogSlowQueries=0 \
  ZS_TmpDir=/tmp \
  ZS_StartProxyPollers=1 \
  ZS_ProxyConfigFrequency=3600 \
  ZS_ProxyDataFrequency=1 \
  ZS_AllowRoot=0 \
  ZS_User=zabbix \
  ZS_Include="" \
  ZS_SSLCertLocation=/usr/local/share/zabbix/ssl/certs \
  ZS_SSLKeyLocation=/usr/local/share/zabbix/ssl/keys \
  ZS_SSLCALocation="" \
  ZS_LoadModulePath=/usr/lib/zabbix/modules \
  ZS_LoadModule="" \
  TERM=xterm

# Layer: base
RUN \
  yum clean all && \
  yum update -y && \
  yum install -y epel-release && \
  sed -i -e "\|^https://\"http://|d" /etc/yum.repos.d/epel.repo && \
  yum clean all && \
  yum install -y supervisor && \
  yum install -y http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
  yum install -y nginx inotify-tools && \
  `# Rename nginx:nginx user/group to www:www, also set uid:gid to 80:80 (just to make it nice)` \
  groupmod --gid 80 --new-name www nginx && \
  usermod --uid 80 --home /data/www --gid 80 --login www --shell /bin/bash --comment www nginx && \
  `# Clean-up /etc/nginx/ directory from all not needed stuff...` \
  rm -rf /etc/nginx/*.d /etc/nginx/*_params && \
  `# Prepare dummy SSL certificates` \
  mkdir -p /etc/nginx/ssl && \
  openssl genrsa -out /etc/nginx/ssl/dummy.key 2048 && \
  openssl req -new -key /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.csr -subj "/C=GB/L=London/O=Company Ltd/CN=zabbix-docker" && \
  openssl x509 -req -days 3650 -in /etc/nginx/ssl/dummy.csr -signkey /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.crt && \
  yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum install -y --enablerepo=remi-php56 php-fpm \
       php-gd php-bcmath php-ctype php-xml php-xmlreader php-xmlwriter \
       php-session php-net-socket php-mbstring php-gettext php-cli \
       php-mysqlnd php-opcache php-pdo php-snmp php-ldap && \
  yum clean all && rm -rf /tmp/*
ADD container-files-base /

# Layer: zabbix
COPY container-files-zabbix /
RUN \
  yum clean all && \
  yum update -y && \
  yum install -y tar svn gcc automake make nmap traceroute iptstate wget \
              net-snmp-devel net-snmp-libs net-snmp net-snmp-perl iksemel \
              net-snmp-python net-snmp-utils java-1.8.0-openjdk python-pip \
              java-1.8.0-openjdk-devel mariadb-devel libxml2-devel gettext \
              libcurl-devel OpenIPMI-devel mysql iksemel-devel libssh2-devel \
              unixODBC unixODBC-devel mysql-connector-odbc postgresql-odbc \
              openldap-devel net-tools snmptt sudo rubygems && \
 `# reinstall glibc for locales` \
  yum -y -q reinstall glibc-common && \
  cp /usr/local/etc/zabbix_agend.conf /tmp && \
  svn co svn://svn.zabbix.com/${ZABBIX_VERSION} /usr/local/src/zabbix && \
  cd /usr/local/src/zabbix && \
  DATE=`date +%Y-%m-%d` && \
  sed -i "s/ZABBIX_VERSION.*'\(.*\)'/ZABBIX_VERSION', '\1 ($DATE)'/g" frontends/php/include/defines.inc.php && \
  sed -i "s/ZABBIX_VERSION_RC.*\"\(.*\)\"/ZABBIX_VERSION_RC \"\1 (${DATE})\"/g" include/version.h && \
  sed -i "s/String VERSION =.*\"\(.*\)\"/String VERSION = \"\1 (${DATE})\"/g" src/zabbix_java/src/com/zabbix/gateway/GeneralInformation.java && \
  ./bootstrap.sh && \
  ./configure --enable-server --enable-agent --with-mysql --enable-java \
              --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi \
              --enable-ipv6 --with-jabber --with-openssl --with-ssh2 \
              --with-ldap  --with-unixodbc && \
  make dbschema && \
  gem install sass && \
  make css && \
  make install && \
  cp /usr/local/etc/web/zabbix.conf.php /usr/local/src/zabbix/frontends/php/conf/ && \
  pip install py-zabbix && \
  wget https://github.com/schweikert/fping/archive/3.10.tar.gz && \
  tar -xvf 3.10.tar.gz && \
  cd fping-3.10/ && \
  ./autogen.sh && \
  ./configure --prefix=/usr --enable-ipv6 --enable-ipv4 && \
  make && \
  make install && \
  setcap cap_net_raw+ep /usr/sbin/fping || echo 'Warning: setcap cap_net_raw+ep /usr/sbin/fping' && \
  setcap cap_net_raw+ep /usr/sbin/fping6 || echo 'Warning: setcap cap_net_raw+ep /usr/sbin/fping6' && \
  chmod 4710 /usr/sbin/fping && \
  chmod 4710 /usr/sbin/fping6 && \
  cd .. && \
  cp -f /tmp/zabbix_agend.conf /usr/local/etc/ && \
  rm -rf fping-3.10 && \
  rm -rf 3.10.tar.gz && \
  cd /usr/local/src/zabbix/frontends/php && \
  locale/make_mo.sh && \
  yum autoremove -y gettext python-pip tar svn gcc automake mariadb-devel \
                    java-1.8.0-openjdk-devel libxml2-devel libcurl-devel \
                    OpenIPMI-devel iksemel-devel rubygems && \
  yum install -y OpenIPMI-libs && \
  chmod +x /config/bootstrap.sh && \
  chmod +x /config/ds.sh && \
  yum clean all && \
  mkdir -p /usr/local/share/ssl/certs && \
  mkdir -p /usr/local/share/ssl/keys && \
  mkdir -p /usr/lib/zabbix/modules && \
  rm -rf /tmp/*

CMD ["/config/bootstrap.sh"]

VOLUME ["/etc/custom-config/", "/usr/local/share/zabbix/externalscripts", "/usr/local/share/zabbix/ssl/certs", "/usr/local/share/zabbix/ssl/keys", "/usr/lib/zabbix/modules"]

EXPOSE 10051 10052 80
