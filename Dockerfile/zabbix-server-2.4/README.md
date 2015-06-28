Zabbix Community Dockerfiles
============================

[Zabbix Github repo](https://github.com/zabbix/zabbix-community-docker) is intended
 as a source for [Zabbix Docker registry](https://registry.hub.docker.com/repos/zabbix/).
Please use these community Zabbix Docker images, if you want to [build/ship your own Zabbix Docker image](https://github.com/zabbix/zabbix-community-docker#how-to-build-own-docker-image).

zabbix-server-2.4 [![Circle CI](https://circleci.com/gh/zabbix/zabbix-community-docker/tree/master.svg?style=svg&circle-token=930b0a85da051123bf3f2c9c28ede5b29c607665)](https://circleci.com/gh/zabbix/zabbix-community-docker/tree/master) [![](https://badge.imagelayers.io/zabbix/zabbix-server-2.4:latest.svg)](https://imagelayers.io/?images=zabbix/zabbix-server-2.4:latest 'Get your own badge on imagelayers.io')
=================

Compiled zabbix-server with almost all features (MySQL, Java, SNMP, Curl, Ipmi) 
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


#### Environmental Variable
In this Image you can use environmental variables to connect into external MySQL/MariaDB database.

`DB_USER` = database user  
`DB_PASS` = database password  
`DB_ADDRESS` = database address (either ip or domain name)

#### Zabbix server deployment
Now when we have Zabbix database running we can deploy zabbix-server image with appropriate environmental variables set.

Example:  

	docker run \
		-d \
		--name zabbix \
		-p 80:80 \
		-p 10051:10051 \
		--env="DB_ADDRESS=database_ip" \
		--env="DB_USER=username" \
		--env="DB_PASS=my_password" \
		zabbix/zabbix-server-2.4
        
#### Access to Zabbix web interface 
To log in into zabbix web interface for the first time use credentials `Admin:zabbix`.  

Access web interface under [http://docker_host.ip]()

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
docker exec -i -t zabbix /bin/bash
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
		--env="DB_ADDRESS=database_ip" \
		--env="DB_USER=username" \
		--env="DB_PASS=my_password" \
		zabbix/zabbix-server-2.4:2.4.4
```