# docker build --rm=true -t zabbix/zabbix-server-2.2 .

FROM centos:centos7
MAINTAINER Jan Garaj jan.garaj@gmail.com

ENV \
  ZABBIX_VERSION=2.2.0 \
  STATUS_PAGE_ALLOWED_IP=127.0.0.1 \
  JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/bin/java \
  JAVA=/usr/lib/jvm/java-1.8.0-openjdk/bin/java \
  DB_ADDRESS=127.0.0.1 DB_USER=admin DB_PASS=password

# Layer: serviced
RUN \
  yum clean all && \
  yum update -y && \
  yum install -y epel-release && \
  yum install -y supervisor && \
  yum clean all && rm -rf /tmp/*    
ADD container-files-serviced /  

# Layer: nginx
RUN \
  yum install -y http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
  yum install -y nginx && \
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
ADD container-files-nginx /
  
# Layer: zabbix
# TODO web ui auto config, timezone env, rm -rf /usr/local/src/zabbix
RUN \
  yum install -y tar svn gcc automake make nmap traceroute iptstate wget \
              net-snmp-devel net-snmp-libs net-snmp net-snmp-perl \
              net-snmp-python net-snmp-utils java-1.8.0-openjdk \
              java-1.8.0-openjdk-devel mariadb-devel libxml2-devel \
              libcurl-devel OpenIPMI-devel mysql && \
  svn co svn://svn.zabbix.com/tags/${ZABBIX_VERSION} /usr/local/src/zabbix && \
  cd /usr/local/src/zabbix && \
  ./bootstrap.sh && \
  ./configure --enable-server --enable-agent --with-mysql --enable-java --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi --enable-ipv6 --with-jabber && \
  make dbschema && \
  make install && \
  wget https://github.com/schweikert/fping/archive/3.10.tar.gz && \
  tar -xvf 3.10.tar.gz && \ 
  cd fping-3.10/ && \
  ./autogen.sh && \ 
  ./configure --prefix=/usr/local --enable-ipv6 --enable-ipv4 && \
  make && \
  make install && \
  setcap cap_net_raw+ep /usr/local/sbin/fping && \
  setcap cap_net_raw+ep /usr/local/sbin/fping6 && \
  cd .. && \
  rm -rf fping-3.10 && \
  rm -rf 3.10.tar.gz && \ 
  yum remove -y tar svn make gcc automake mariadb-devel java-1.8.0-openjdk-devel libxml2-devel libcurl-devel OpenIPMI-devel && \
  chmod +x /config/bootstrap.sh && \ 
  yum clean all && rm -rf /tmp/*  
COPY container-files-zabbix /

#ENTRYPOINT ["/config/bootstrap.sh"]

EXPOSE 10051 10052 80
