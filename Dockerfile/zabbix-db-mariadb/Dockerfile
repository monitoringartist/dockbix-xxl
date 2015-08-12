# docker build --rm=true -t jangaraj/zabbix-db-mariadb .

FROM centos:centos7
MAINTAINER Jan Garaj info@monitoringartist.com

ENV \
  DB_max_allowed_packet=16M \	
  DB_query_cache_size=0 \
  DB_query_cache_type=0 \
  DB_sync_binlog=0 \	
  DB_innodb_buffer_pool_size=768M \
  DB_innodb_log_file_size=128M \
  DB_innodb_flush_method=O_DIRECT \
  DB_innodb_old_blocks_time=1000 \
  DB_innodb_flush_log_at_trx_commit=0

COPY container-files/ /tmp/

RUN \
    yum update -y && \
    cp /tmp/etc/yum.repos.d/* /etc/yum.repos.d/ && \
    yum install -y epel-release && \
    yum install -y MariaDB-server hostname net-tools pwgen && \
    yum clean all && \
    cp -f -r /tmp/etc/* /etc/ && \
    cp -f /tmp/*.sh / && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/mysql/*

# Add VOLUME to allow backup of data
VOLUME ["/var/lib/mysql"]

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm

EXPOSE 3306
CMD ["/run.sh"]
