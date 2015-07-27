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
  yum update -y && \
  yum install -y epel-release && \
  yum install -y net-tools python-setuptools hostname inotify-tools yum-utils && \
  yum clean all && \
  easy_install supervisor  
ADD container-files-serviced /  

# Layer: nginx
RUN \
  rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
  yum install -y nginx && \
  yum clean all && \
  `# Rename nginx:nginx user/group to www:www, also set uid:gid to 80:80 (just to make it nice)` \
  groupmod --gid 80 --new-name www nginx && \
  usermod --uid 80 --home /data/www --gid 80 --login www --shell /bin/bash --comment www nginx && \
  `# Clean-up /etc/nginx/ directory from all not needed stuff...` \
  rm -rf /etc/nginx/*.d /etc/nginx/*_params && \
  `# Prepare dummy SSL certificates` \
  mkdir -p /etc/nginx/ssl && \
  openssl genrsa -out /etc/nginx/ssl/dummy.key 2048 && \
  openssl req -new -key /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.csr -subj "/C=GB/L=London/O=Company Ltd/CN=docker" && \
  openssl x509 -req -days 3650 -in /etc/nginx/ssl/dummy.csr -signkey /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.crt
ADD container-files-nginx /

# Layer: nginx-php
ADD container-files-nginx-php/config/install* /config/
RUN \
  rpm --rebuilddb && yum update -y && \
  `# Install yum-utils (provides yum-config-manager) + some basic web-related tools...` \
  yum install -y yum-utils wget patch mysql tar bzip2 unzip openssh-clients && \
  `# Install PHP 5.6` \
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum-config-manager -q --enable remi && \
  yum-config-manager -q --enable remi-php56 && \
  yum install -y php-fpm php-bcmath php-cli php-gd php-intl php-mbstring \
                  php-pecl-imagick php-mcrypt php-mysql php-opcache php-pdo && \
  yum install -y --disablerepo=epel php-pecl-redis php-pecl-yaml && \
  `# Install libs required to build some gem/npm packages (e.g. PhantomJS requires zlib-devel, libpng-devel)` \
  yum install -y ImageMagick GraphicsMagick gcc gcc-c++ libffi-devel libpng-devel zlib-devel && \
  `# Install common tools needed/useful during Web App development` \
  `# Install Ruby 2` \
  yum install -y ruby ruby-devel && \
  `# Install/compile other software (Git, NodeJS)` \
  source /config/install.sh && \
  yum clean all && rm -rf /tmp/yum* && \
  `# Install common npm packages: grunt, gulp, bower, browser-sync` \
  npm install -g gulp grunt-cli bower browser-sync && \
  `# Update RubyGems, install Bundler` \
  echo 'gem: --no-document' > /etc/gemrc && gem update --system && gem install bundler && \
  `# Disable SSH strict host key checking: needed to access git via SSH in non-interactive mode` \
  echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  chown www /usr/local/bin/composer &&\
  yum clean all &&\
  yum autoremove -y tar bzip2 unzip gcc gcc-c++ libffi-devel libpng-devel zlib-devel
COPY container-files-nginx-php /
  
# Layer: zabbix
RUN \
  yum clean all && yum makecache && \
  yum update --nogpgcheck -y && \
  yum install --nogpgcheck -y svn gcc automake make nmap traceroute iptstate wget sudo net-snmp-devel net-snmp-libs net-snmp net-snmp-perl net-snmp-python net-snmp-utils php-snmp php-ldap java-1.8.0-openjdk java-1.8.0-openjdk-devel mariadb-devel libxml2-devel libcurl-devel OpenIPMI-devel fping && \
  svn co svn://svn.zabbix.com/tags/${ZABBIX_VERSION} /usr/local/src/zabbix && \
  cd /usr/local/src/zabbix && \
  ./bootstrap.sh && \
  ./configure --enable-server --enable-agent --with-mysql --enable-java --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi && \
  make dbschema && \
  make install && \
  rpm -e --nodeps make gcc && \
  yum remove -y svn gcc automake mariadb-devel java-1.8.0-openjdk-devel libxml2-devel libcurl-devel OpenIPMI-devel && \
  rm -rf /usr/local/src/zabbix &&\
  rm -rf /tmp/* &&\
  yum clean all
COPY container-files-zabbix /

EXPOSE 10051 10052 80
