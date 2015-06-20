FROM million12/nginx-php
MAINTAINER Przemyslaw Ozgo linux@ozgo.info

ENV ZABBIX_VERSION=2.2.0

RUN \
  yum clean all && yum makecache && \
  yum update --nogpgcheck -y && \
  yum install --nogpgcheck -y svn gcc automake make nmap traceroute iptstate wget sudo net-snmp-devel net-snmp-libs net-snmp net-snmp-perl net-snmp-python net-snmp-utils php-snmp php-ldap java-1.8.0-openjdk java-1.8.0-openjdk-devel mariadb-devel libxml2-devel libcurl-devel OpenIPMI-devel && \
  svn co svn://svn.zabbix.com/tags/${ZABBIX_VERSION} /usr/local/src/zabbix && \
  cd /usr/local/src/zabbix && \
  ./bootstrap.sh && \
  ./configure --enable-server --enable-agent --with-mysql --enable-java --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi && \
  make dbschema && \
  make install && \
  rpm -e --nodeps make gcc && \
  yum remove -y svn automake mariadb-devel java-1.8.0-openjdk-devel libxml2-devel libcurl-devel OpenIPMI-devel && \
  yum clean all

ENV \
  JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/bin/java \
  JAVA=/usr/lib/jvm/java-1.8.0-openjdk/bin/java \
  DB_ADDRESS=127.0.0.1 DB_USER=admin DB_PASS=password

COPY container-files /


EXPOSE 10051 10052 80
