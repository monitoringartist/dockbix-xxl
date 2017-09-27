FROM centos:centos7
LABEL maintainer "Jan Garaj <info@monitoringartist.com>"

# ZABBIX_VERSION=trunk tags/3.0.1 branches/dev/ZBXNEXT-1263-1

ENV \
  ZABBIX_VERSION=tags/3.2.6 \
  ZS_enabled=true \
  ZA_enabled=true \
  ZW_enabled=true \
  ZJ_enabled=false \
  ZP_enabled=false \
  SNMPTRAP_enabled=false \
  STATUS_PAGE_ALLOWED_IP=127.0.0.1 \
  JAVA_HOME=/usr/lib/jvm/jre \
  JAVA=/usr/bin/java \
  PHP_date_timezone=UTC \
  PHP_max_execution_time=300 \
  PHP_max_input_time=300 \
  PHP_memory_limit=128M \
  PHP_error_reporting=E_ALL \
  ZS_LogType=console \
  ZS_PidFile=/var/run/zabbix_server.pid \
  ZS_User=zabbix \
  ZS_DBHost=zabbix.db \
  ZS_DBName=zabbix \
  ZS_DBUser=zabbix \
  ZS_DBPassword=zabbix \
  ZS_DBPort=3306 \
  ZS_PidFile=/tmp/zabbix_server.pid \
  ZS_AlertScriptsPath=/usr/local/share/zabbix/alertscripts \
  ZS_ExternalScripts=/usr/local/share/zabbix/externalscripts \
  ZS_SSLCertLocation=/usr/local/share/zabbix/ssl/certs \
  ZS_SSLKeyLocation=/usr/local/share/zabbix/ssl/keys \
  ZS_LoadModulePath=/usr/lib/zabbix/modules \
  ZW_ZBX_SERVER=localhost \
  ZW_ZBX_SERVER_PORT=10051 \
  ZW_ZBX_SERVER_NAME="Zabbix Server" \
  ZA_LogType=console \
  ZA_Hostname="Zabbix Server" \
  ZA_User=zabbix \
  ZA_PidFile=/tmp/zabbix_agentd.pid \
  ZA_Server=127.0.0.1 \
  ZA_ServerActive=127.0.0.1 \
  ZJ_LISTEN_IP=0.0.0.0 \
  ZJ_LISTEN_PORT=10052 \
  ZJ_PID_FILE=/tmp/zabbix_java.pid \
  ZJ_START_POLLERS=5 \
  ZJ_TIMEOUT=3 \
  ZJ_LogLevel=error \
  ZJ_TCP_TIMEOUT=3000 \
  ZP_LogType=console \
  ZP_DBHost=zabbixproxy.db \
  ZP_DBName=zabbix \
  ZP_DBUser=zabbix \
  ZP_DBPassword=zabbix \
  ZP_User=zabbix \
  XXL_searcher=true \
  XXL_updatechecker=true \
  XXL_zapix=false \
  XXL_grapher=false \
  XXL_api=true \
  XXL_apiuser=Admin \
  XXL_apipass=zabbix \
  XXL_analytics=true \
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
              net-snmp-python net-snmp-utils java-1.8.0-openjdk \
              java-1.8.0-openjdk-devel mariadb-devel libxml2-devel gettext \
              libcurl-devel OpenIPMI-devel mysql iksemel-devel libssh2-devel \
              unixODBC unixODBC-devel mysql-connector-odbc postgresql-odbc \
              openldap-devel telnet net-tools snmptt sudo rubygems ruby-devel jq \
              openssh-clients python-httplib2 python-simplejson \
              libevent-devel openldap-clients && \
 `# reinstall glibc for locales` \
  yum -y -q reinstall glibc-common && \
  cp /usr/local/etc/zabbix_agentd.conf /tmp && \
  svn co svn://svn.zabbix.com/${ZABBIX_VERSION} /usr/local/src/zabbix && \
  cd /usr/local/src/zabbix && \
  DATE=`date +%Y-%m-%d` && \
  sed -i "s/ZABBIX_VERSION.*'\(.*\)'/ZABBIX_VERSION', '\1 ($DATE)'/g" frontends/php/include/defines.inc.php && \
  sed -i "s/ZABBIX_VERSION_RC.*\"\(.*\)\"/ZABBIX_VERSION_RC \"\1 (${DATE})\"/g" include/version.h && \
  sed -i "s/String VERSION =.*\"\(.*\)\"/String VERSION = \"\1 (${DATE})\"/g" src/zabbix_java/src/com/zabbix/gateway/GeneralInformation.java && \
  zabbix_revision=$(svn info svn://svn.zabbix.com/${ZABBIX_VERSION} |grep "Last Changed Rev"|awk '{print $4;}') && \
  sed -i "s/{ZABBIX_REVISION}/$zabbix_revision/g" include/version.h && \
  ./bootstrap.sh && \
  ./configure --enable-server --enable-agent --with-mysql --enable-java \
              --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi \
              --enable-ipv6 --with-jabber --with-openssl --with-ssh2 \
              --enable-proxy --with-ldap --with-unixodbc && \
  make -j"$(nproc)" dbschema && \
  gem install sass && \
  make css && \
  make -j"$(nproc)" install && \
  mv /health/ /usr/local/src/zabbix/frontends/php/ && \
  cp /usr/local/etc/web/zabbix.conf.php /usr/local/src/zabbix/frontends/php/conf/ && \
  wget https://github.com/schweikert/fping/archive/3.10.tar.gz && \
  tar -xvf 3.10.tar.gz && \
  cd fping-3.10/ && \
  ./autogen.sh && \
  ./configure --prefix=/usr --enable-ipv6 --enable-ipv4 && \
  make -j"$(nproc)" && \
  make -j"$(nproc)" install && \
  setcap cap_net_raw+ep /usr/sbin/fping || echo 'Warning: setcap cap_net_raw+ep /usr/sbin/fping' && \
  setcap cap_net_raw+ep /usr/sbin/fping6 || echo 'Warning: setcap cap_net_raw+ep /usr/sbin/fping6' && \
  chmod 4710 /usr/sbin/fping && \
  chmod 4710 /usr/sbin/fping6 && \
  cd .. && \
  cp -f /tmp/zabbix_agentd.conf /usr/local/etc/ && \
  rm -rf fping-3.10 && \
  rm -rf 3.10.tar.gz && \
  cd /usr/local/src/zabbix/frontends/php && \
  locale/make_mo.sh && \
  yum autoremove -y gettext svn gcc automake mariadb-devel \
                    java-1.8.0-openjdk-devel libxml2-devel libcurl-devel \
                    OpenIPMI-devel iksemel-devel rubygems ruby-devel kernel-headers && \
  yum install -y OpenIPMI-libs && \
  chmod +x /config/bootstrap.sh && \
  chmod +x /config/ds.sh && \
  chmod +x /usr/local/src/zabbix/misc/snmptrap/zabbix_trap_receiver.pl && \
  chmod +x /usr/share/snmptt/snmptthandler-embedded && \
  sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && \
  yum clean all && \
  mkdir -p /usr/local/share/ssl/certs && \
  mkdir -p /usr/local/share/ssl/keys && \
  mkdir -p /usr/lib/zabbix/modules && \
  mkdir -p /etc/zabbix/snmp/mibs && \
  rm -rf /usr/local/src/zabbix/[a,A,b,c,C,i,I,m,M,n,N,r,R,s,t,u,r,\.]* /usr/local/src/zabbix/depcomp /usr/local/src/zabbix/.svn && \
  rm -rf /usr/local/src/zabbix/database/[i,M,o,p,s]* && \
  rm -rf /tmp/*
  # TODO apply http://geofrogger.net/review/snmptt-hide-generic-part.patch

# Layer: zabbix-xxl
COPY container-files-zabbix-xxl /
RUN \
  ### locales fix && \
  yum -y -q reinstall glibc-common && \
  cd /tmp && \
  yumdownloader glibc-common && \
  rpm2cpio glibc-common*.rpm | cpio -idmv && \
  rm -vf /usr/lib/locale/locale-archive.tmpl && \
  cp -vf ./usr/lib/locale/locale-archive.tmpl /usr/lib/locale/ && \
  build-locale-archive && \
  rm -rf /tmp/* && \
  ### japanese font and boto ### && \
  yum install -y ipa-pgothic-fonts python-boto python-pip && \
  cp /usr/share/fonts/ipa-pgothic/ipagp.ttf /usr/local/src/zabbix/frontends/php/fonts && \
  pip install pyzabbix && \
  yum autoremove -y ipa-pgothic-fonts python-pip && \
  yum clean all && \
  ### branding / menu ### && \
  sed -i "s/ZABBIX_VERSION.*'\(.*\)'/ZABBIX_VERSION', '\1 XXL'/g" /usr/local/src/zabbix/frontends/php/include/defines.inc.php && \
  grep 'XXL' /usr/local/src/zabbix/frontends/php/include/defines.inc.php && \
  sed -i "s#]))->addClass(ZBX_STYLE_FOOTER);#,' / ',(new CLink('Monitoring Artist Ltd', 'http://www.monitoringartist.com'))->addClass(ZBX_STYLE_GREY)->addClass(ZBX_STYLE_LINK_ALT)->setAttribute('target', '_blank'),]))->addClass(ZBX_STYLE_FOOTER);#g" /usr/local/src/zabbix/frontends/php/include/html.inc.php && \
  grep 'www.monitoringartist.com' /usr/local/src/zabbix/frontends/php/include/html.inc.php && \
  sed -i "s/(new CDiv())->addClass(ZBX_STYLE_SIGNIN_LOGO),/(new CDiv())->addClass(ZBX_STYLE_SIGNIN_LOGO),(new CDiv())->addClass(ZBX_STYLE_CENTER)->addItem((new CTag('h1', true, _('Zabbix XXL')))->addClass(ZBX_STYLE_BLUE))->addItem((new CLink(_('Maintained by Monitoring Artist'), 'http:\/\/www.monitoringartist.com'))->setTarget('_blank')->addClass(ZBX_STYLE_GREY)),/g" /usr/local/src/zabbix/frontends/php/include/views/general.login.php && \
  grep 'www.monitoringartist.com' /usr/local/src/zabbix/frontends/php/include/views/general.login.php && \
  sed -i "s#echo '</body></html>';#echo \"<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');ga('create','UA-72810204-2','auto');ga('send','pageview');</script></body></html>\";#g" /usr/local/src/zabbix/frontends/php/include/page_footer.php && \
  grep 'UA-72810204-2' /usr/local/src/zabbix/frontends/php/include/page_footer.php && \
  sed -i "s#echo '</body></html>';#echo \"<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');ga('create','UA-72810204-2','auto');ga('send','pageview');</script></body></html>\";#g" /usr/local/src/zabbix/frontends/php/app/views/layout.htmlpage.php && \
  grep 'UA-72810204-2' /usr/local/src/zabbix/frontends/php/app/views/layout.htmlpage.php && \
  ZVERSION=$(zabbix_agentd -V | grep ^zabbix_agentd | awk -F'\\(Zabbix\\) ' '{print $2}') && \
  sed -i "s#^var xxlCurrentVersion =.*#var xxlCurrentVersion = \"$ZVERSION\";#" /usr/local/src/zabbix/frontends/php/updatechecker/updatechecker.js && \
  grep "$ZVERSION" /usr/local/src/zabbix/frontends/php/updatechecker/updatechecker.js && \
  sed -i "s#.*</body></html>.*#echo \"<script type='text/javascript' src='updatechecker/updatechecker.js'></script>\";\n&#" /usr/local/src/zabbix/frontends/php/include/page_footer.php && \
  grep 'updatechecker.js' /usr/local/src/zabbix/frontends/php/include/page_footer.php && \
  sed -i "s#</body></html>#<script type='text/javascript' src='updatechecker/updatechecker.js'></script></body></html>#g" /usr/local/src/zabbix/frontends/php/app/views/layout.htmlpage.php && \
  grep 'updatechecker.js' /usr/local/src/zabbix/frontends/php/app/views/layout.htmlpage.php && \
  sed -i "s#'login' => \[#'xxl' => \n[\n'label' => _('XXL extensions'),\n'user_type' => USER_TYPE_SUPER_ADMIN,\n'default_page_id' => 0,\n'pages' => [\n['url' => 'searcher.php','label' => _('Searcher'),],\n['url' => 'zapix.php','label' => _('Zapix'),],\n['url' => 'grapher.php','label' => _('Grapher'),],\n['url' => 'about.php','label' => _('About'),]\n]],\n'login' => [#g" /usr/local/src/zabbix/frontends/php/include/menu.inc.php && \
  grep 'XXL extensions' /usr/local/src/zabbix/frontends/php/include/menu.inc.php && \
  sed -i "s#'admin': 0},# 'admin': 0, 'xxl': 0},#g" /usr/local/src/zabbix/frontends/php/js/main.js && \
  grep "'xxl': 0}" /usr/local/src/zabbix/frontends/php/js/main.js && \
  #sed -i "s#case PAGE_TYPE_XML:#case PAGE_TYPE_PEM:\nheader('Content-Type: application/x-pem-file');\nheader('Content-Disposition: attachment; filename=\"'.\$page['file'].'\"');\nbreak;\ncase PAGE_TYPE_XML:#g" /usr/local/src/zabbix/frontends/php/include/page_header.php && \
  #grep 'case PAGE_TYPE_PEM:' /usr/local/src/zabbix/frontends/php/include/page_header.php && \
  #sed -i "s#define('PAGE_TYPE_HTML'#define('PAGE_TYPE_PEM',-1);\ndefine('PAGE_TYPE_HTML'#g" /usr/local/src/zabbix/frontends/php/include/defines.inc.php && \
  #grep 'PAGE_TYPE_PEM' /usr/local/src/zabbix/frontends/php/include/defines.inc.php
  rm -rf /tmp/*

CMD ["/config/bootstrap.sh"]

VOLUME ["/etc/custom-config", "/usr/local/share/zabbix/alertscripts", "/usr/local/share/zabbix/externalscripts", "/usr/local/share/zabbix/ssl/certs", "/usr/local/share/zabbix/ssl/keys", "/usr/lib/zabbix/modules", "/usr/share/snmp/mibs", "/etc/snmp", "/etc/openldap/"]

EXPOSE 80/TCP 162/UDP 10051/TCP 10052/TCP
