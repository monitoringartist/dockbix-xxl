Zabbix Community Dockerfiles
============================

[Zabbix Github repo](https://github.com/zabbix/zabbix-community-docker) is intended
 as a source for [Zabbix Docker registry](https://registry.hub.docker.com/repos/zabbix/).
Please use these community Zabbix Docker images, if you want to [build/ship your own Zabbix Docker image](https://github.com/zabbix/zabbix-community-docker#how-to-build-own-docker-image).

zabbix-server-2.4 [![Circle CI](https://circleci.com/gh/zabbix/zabbix-community-docker/tree/master.svg?style=svg&circle-token=930b0a85da051123bf3f2c9c28ede5b29c607665)](https://circleci.com/gh/zabbix/zabbix-community-docker/tree/master) [![](https://badge.imagelayers.io/zabbix/zabbix-server-2.4:latest.svg)](https://imagelayers.io/?images=zabbix/zabbix-server-2.4:latest 'Get your own badge on imagelayers.io')
=================

Compiled zabbix-server with almost all features (MySQL, Java, SNMP, Curl, IPMI) 
and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. Image requires external 
MySQL database (you can run MySQL also as Docker container).

#### Zabbix database as Docker container
To be able to connect to database we would need one to be running first. 
Easiest way to do that is to use another docker image. 
For this purpose you can use [million12/mariadb](https://registry.hub.docker.com/u/million12/mariadb/)
 image as database.

**For more information about million12/MariaDB see [documentation.](https://github.com/million12/docker-mariadb) **

Example:  

	docker run \
		-d \
		--name zabbix-db \
		-p 3306:3306 \
		--env="MARIADB_USER=username" \
		--env="MARIADB_PASS=my_password" \
		million12/mariadb

_Remember to use the same credentials when deploying zabbix-server image._


#### Environmental variables
In this Image you can use environmental variables to config Zabbix server and PHP. Available variables:

| Variable | Default value |
| -------- | ------------- |
| PHP_date_timezone | UTC |
| PHP_max_execution_time | 300 |
| PHP_max_input_time | 300 |
| PHP_memory_limit | 128M |
| PHP_error_reporting | E_ALL |
| ZS_ListenPort | 10051 |
| ZS_SourceIP | |
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

#### Configuration from volumes
Full config files can be also used. Environment configs will be overriden by values from config files in this case. You need only to add */etc/custom-config/* volume:

```
-v /host/custom-config/:/etc/custom-config/
```

Available files:
| File | Description |
| ---- | ----------- |
| php-zabbix.ini | PHP configuration file |
| zabbix_server.conf | Zabbix server configuration file |


#### Zabbix server deployment
Now when we have Zabbix database running we can deploy zabbix-server image with appropriate environmental variables set.

Example:  

	docker run \
		-d \
		--name zabbix \
		-p 80:80 \
		-p 10051:10051 \
		--env="ZS_DBHost=database_ip" \
		--env="ZS_DBUser=username" \
		--env="ZS_DBPassword=my_password" \
		zabbix/zabbix-server-2.4
        
#### Access to Zabbix web interface 
To log in into zabbix web interface for the first time use credentials `Admin:zabbix`.  

Access web interface under [http://docker_host_ip]()

Docker troubleshooting
======================

Use docker command to see if all required containers are up and running: 
```
$ docker ps -f
```
Check online logs of Zabbix container:
```
$ docker logs zabbix
```
Attach to running Zabbix container (to detach the tty without exiting the shell, 
use the escape sequence Ctrl+p + Ctrl+q):
```
$ docker attach zabbix
```
Sometimes you might just want to review how things are deployed inside a running container, you can do this by executing a _bash shell_ through _docker's exec_ command:
```
docker exec -ti zabbix /bin/bash
```
History of an image and size of layers: 
``` 
docker history --no-trunc=true zabbix/zabbix-server-2.4 | tr -s ' ' | tail -n+2 | awk -F " ago " '{print $2}'
```
Run specific Zabbix version, e.g. 2.4.4 - just specify 2.4.4 tag for image:
```
	docker run \
		-d \
		--name zabbix \
		-p 80:80 \
		-p 10051:10051 \
		--env="ZS_DBHost=database_ip" \
		--env="ZS_DBUser=username" \
		--env="ZS_DBPassword=my_password" \
		zabbix/zabbix-server-2.4:2.4.4
```
