Zabbix Dockerfiles
==================

[Zabbix XXL GitHub repo](https://github.com/monitoringartist/zabbix-xxl) is
intended as a source for [Zabbix Docker registry](https://registry.hub.docker.com/repos/zabbix/).
Please use these Zabbix Docker images, if you want to
[build/ship own Zabbix Docker image](https://github.com/monitoringartist/zabbix-xxl#how-to-build-own-docker-image).

zabbix-3.0 [![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-3.0/) [![](https://badge.imagelayers.io/zabbix/zabbix-3.0:dev.svg)](https://imagelayers.io/?images=zabbix/zabbix-3.0:dev)
=================

Compiled Zabbix (server, proxy, agent, java gateway) with almost all features (MySQL support, Java, SNMP,
Curl, IPMI, IPv6, Jabber, fping) and Zabbix web UI based on CentOS 7,
Supervisor, Nginx, PHP. Image requires external MySQL/MariaDB database (you can
run MySQL/MariaDB also as Docker container).

#### Standard Dockerized Zabbix deployment

```
# create /var/lib/mysql as persistent volume storage
docker run -d -v /var/lib/mysql --name zabbix-db-storage busybox:latest

# start DB for Zabbix - default 1GB innodb_buffer_pool_size is used
docker run \
    -d \
    --name zabbix-db \
    -v /backups:/backups \
    -v /etc/localtime:/etc/localtime:ro \
    --volumes-from zabbix-db-storage \
    --env="MARIADB_USER=zabbix" \
    --env="MARIADB_PASS=my_password" \
    zabbix/zabbix-db-mariadb

# start Zabbix linked to started DB
docker run \
    -d \
    --name zabbix \
    -p 80:80 \
    -p 10051:10051 \
    -v /etc/localtime:/etc/localtime:ro \
    --link zabbix-db:zabbix.db \
    --env="ZS_DBHost=zabbix.db" \
    --env="ZS_DBUser=zabbix" \
    --env="ZS_DBPassword=my_password" \
    zabbix/zabbix-3.0:latest
# wait ~60 seconds for Zabbix initialization
# Zabbix web will be available on the port 80, Zabbix server on the port 10051

# Backup of Zabbix configuration data only
docker exec \
    -ti zabbix-db \
    /zabbix-backup/zabbix-mariadb-dump -u zabbix -p my_password -o /backups

# Full DB backup of Zabbix
docker exec \
    -ti zabbix-db \
    bash -c "\
    mysqldump -u zabbix -pmy_password zabbix | \
    bzip2 -cq9 > /backups/zabbix_db_dump_$(date +%Y-%m-%d-%H.%M.%S).sql.bz2"
```

#### Up and Running with Docker Compose

```
docker-compose up -d
```

### Zabbix database as Docker container
To be able to connect to database we would need one to be running first.
Easiest way to do that is to use another docker image. For this purpose you
can use [zabbix/zabbix-db-mariadb]
(https://registry.hub.docker.com/u/zabbix/zabbix-db-mariadb) image as database.

For more information about zabbix/zabbix-db-mariadb see
[README of zabbix-db-mariadb]
(https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-db-mariadb).

Example:

	docker run \
		-d \
		--name zabbix-db \
		-p 3306:3306 \
		-v /etc/localtime:/etc/localtime:ro \
		--env="MARIADB_USER=zabbix" \
		--env="MARIADB_PASS=my_password" \
		zabbix/zabbix-db-mariadb

Remember to use the same credentials when deploying zabbix image.

#### Environmental variables
You can use environmental variables to config Zabbix and Zabbix web UI (PHP). Available
variables:

| Variable | Default value |
| -------- | ------------- |
| PHP_date_timezone | UTC |
| PHP_max_execution_time | 300 |
| PHP_max_input_time | 300 |
| PHP_memory_limit | 128M |
| PHP_error_reporting | E_ALL |
| ZS_ListenPort | 10051 |
| ZS_SourceIP | |
| ZS_LogType | file |
| ZS_LogFile | /tmp/zabbix_server.log |
| ZS_LogFileSize | 10 |
| ZS_DebugLevel | 3 |
| ZS_PidFile | /var/run/zabbix_server.pid |
| ZS_DBHost | zabbix.db |
| ZS_DBName | zabbix |
| ZS_DBSchema | |
| ZS_DBUser | zabbix |
| ZS_DBPassword | zabbix |
| ZS_DBSocket | /tmp/mysql.sock |
| ZS_DBPort | 3306 |
| ZS_StartPollers | 5 |
| ZS_StartPollersUnreachable | 1 |
| ZS_StartTrappers | 5 |
| ZS_StartPingers | 1 |
| ZS_StartDiscoverers | 1 |
| ZS_StartHTTPPollers | 1 |
| ZS_StartIPMIPollers | 0 |
| ZS_StartTimers | 1 |
| ZS_JavaGateway | 127.0.0.1 |
| ZS_JavaGatewayPort | 10052 |
| ZS_StartJavaPollers | 0 |
| ZS_StartVMwareCollectors | 0 |
| ZS_VMwareFrequency | 60 |
| ZS_VMwarePerfFrequency | 60 |
| ZS_VMwareCacheSize | 8M |
| ZS_VMwareTimeout | 10 |
| ZS_SNMPTrapperFile | /tmp/zabbix_traps.tmp |
| ZS_StartSNMPTrapper | 0 |
| ZS_ListenIP | 0.0.0.0 |
| ZS_HousekeepingFrequency | 1 |
| ZS_MaxHousekeeperDelete | 500 |
| ZS_SenderFrequency | 30 |
| ZS_CacheSize | 8M |
| ZS_CacheUpdateFrequency | 60 |
| ZS_StartDBSyncers | 4 |
| ZS_HistoryCacheSize | 8M |
| ZS_TrendCacheSize | 4M |
| ZS_HistoryTextCacheSize | 16M |
| ZS_ValueCacheSize | 8M |
| ZS_Timeout | 3 |
| ZS_TrapperTimeout | 300 |
| ZS_UnreachablePeriod | 45 |
| ZS_UnavailableDelay | 60 |
| ZS_UnreachableDelay | 15 |
| ZS_AlertScriptsPath | /usr/local/share/zabbix/alertscripts |
| ZS_ExternalScripts | /usr/local/share/zabbix/externalscripts |
| ZS_FpingLocation | /usr/sbin/fping |
| ZS_Fping6Location | /usr/sbin/fping6 |
| ZS_SSHKeyLocation | |
| ZS_LogSlowQueries | 0 |
| ZS_TmpDir | /tmp |
| ZS_StartProxyPollers | 1 |
| ZS_ProxyConfigFrequency | 3600 |
| ZS_ProxyDataFrequency | 1 |
| ZS_AllowRoot | 0 |
| ZS_User | zabbix |
| ZS_Include | |
| ZS_SSLCertLocation | /usr/local/share/zabbix/ssl/certs |
| ZS_SSLKeyLocation | /usr/local/share/zabbix/ssl/keys |
| ZS_SSLCALocation | |
| ZS_LoadModulePath | /usr/lib/zabbix/modules |
| ZS_LoadModule | |
| ZS_TLSCAFile | |
| ZS_TLSCRLFile | |
| ZS_TLSCertFile | |
| ZS_TLSKeyFile | |
| ZW_ZBX_SERVER | localhost |
| ZW_ZBX_SERVER_PORT | 10051 |
| ZW_ZBX_SERVER_NAME | Zabbix Server |
| ZJ_LISTEN_IP | 0.0.0.0 |
| ZJ_LISTEN_PORT | 10052 |
| ZJ_PID_FILE | /tmp/zabbix_java.pid |
| ZJ_START_POLLERS | 5 |
| ZJ_TIMEOUT | 3 |
| ZJ_LogLevel | error |
| ZJ_TCP_TIMEOUT | 3000 |
| ZP_LogType | console |
| ZP_DBHost | zabbixproxy.db |
| ZP_DBName | zabbix |
| ZP_DBUser | zabbix |
| ZP_DBPassword | zabbix |
| ZP_DBPort | 3306 |
| ZP_User | zabbix |

#### Configuration from volume
Full config files can be also used. Environment configs will be overridden by
values from config files in this case. You need only to add */etc/custom-config/*
 volume:

```
-v /host/custom-config/:/etc/custom-config/
```

Available files:

| File | Description |
| ---- | ----------- |
| php-zabbix.ini | PHP configuration file |
| zabbix_server.conf | Zabbix server configuration file |
| zabbix_proxy.conf | Zabbix proxy configuration file |
| logback.xml | Zabbix Java gateway log configuration file |

Zabbix role environment variables:

| Variable | Default value | Description |
| -------- | ------------- | ----------- |
| ZS_enabled | true | Zabbix Server start |
| ZA_enabled | true | Zabbix Agent start |
| ZW_enabled | true | Zabbix Web UI start |
| ZP_enabled | false | Zabbix Proxy start |
| ZJ_enabled | false | Zabbix Java Gateway start |
| SNMPTRAP_enabled | false | SNMP trap process (port 162) start |

All Zabbix components are enabled by default except SNMP traps processing. However users
want to run dedicated Zabbix component per container. Typical use case is Zabbix
web UI. Thanks to role environment variables are users able to execute many web
UI containers, which helps to scale Zabbix as a service.


#### Zabbix deployment
Now when we have Zabbix database running we can deploy Zabbix image with
appropriate environmental variables set.

Example:

	docker run \
		-d \
		--name zabbix \
		-p 80:80 \
		-p 10051:10051 \
		-v /etc/localtime:/etc/localtime:ro \
		--link zabbix-db:zabbix.db \
		--env="ZS_DBHost=zabbix.db" \
		--env="ZS_DBUser=zabbix" \
		--env="ZS_DBPassword=my_password" \
		zabbix/zabbix-3.0:latest

#### Access to Zabbix web interface
To log in into Zabbix web interface for the first time use credentials
`Admin:zabbix`.

Access web interface under [http://docker_host_ip]()

#### HTTPS web interface

Set up nginx - customize [default.conf](https://github.com/monitoringartist/zabbix-xxl/blob/master/Dockerfile/zabbix-3.0/container-files-zabbix/etc/nginx/hosts.d/default.conf)
and then use volume to mount custom nginx configuration (for example `-v /etc/https-zabbix-nginx.conf:/etc/nginx/hosts.d/default.conf`) + mount also certificates used in your custom nginx conf file.

Docker troubleshooting
======================

Use docker command to see if all required containers are up and running:
```
$ docker ps
```

Check logs of Zabbix container:
```
$ docker logs zabbix
```

Sometimes you might just want to review how things are deployed inside a running
 container, you can do this by executing a _bash shell_ through _docker's
 exec_ command:
```
docker exec -ti zabbix /bin/bash
```

History of an image and size of layers:
```
docker history --no-trunc=true zabbix/zabbix-3.0 | tr -s ' ' | tail -n+2 | awk -F " ago " '{print $2}'
```

Run specific Zabbix version, e.g. 3.0.0 - just specify 3.0.0 tag for image:
```
	docker run \
		-d \
		--name zabbix \
		-p 80:80 \
		-p 10051:10051 \
		-v /etc/localtime:/etc/localtime:ro \
		--link zabbix-db:zabbix.db \
		--env="ZS_DBHost=zabbix.db" \
		--env="ZS_DBUser=zabbix" \
		--env="ZS_DBPassword=my_password" \
		zabbix/zabbix-3.0:3.0.0
```

Related Zabbix Docker projects
==============================

* [Zabbix agent 3.0 XXL with Docker monitoring support](https://github.com/monitoringartist/zabbix-agent-xxl)
* Dockerised project [Grafana XXL](https://github.com/monitoringartist/grafana-xxl), which includes also [Grafana Zabbix datasource](https://github.com/alexanderzobnin/grafana-zabbix)
* Scale your Dockerised [Zabbix with Kubernetes](https://github.com/monitoringartist/kubernetes-zabbix)
