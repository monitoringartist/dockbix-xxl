Zabbix Community Dockerfiles
============================

[Zabbix Github repo](https://github.com/zabbix/zabbix-community-docker) is intended
 as a source for [Zabbix Docker registry](https://registry.hub.docker.com/repos/zabbix/).
Please use these community Zabbix Docker images, if you want to [build/ship your own Zabbix Docker image](https://github.com/zabbix/zabbix-community-docker#how-to-build-own-docker-image).

Available images
================

### 1. zabbix-server
 
#### [Docker image zabbix-server-2.4](https://registry.hub.docker.com/u/zabbix/zabbix-server-2.4/) [![Circle CI](https://circleci.com/gh/zabbix/zabbix-community-docker/tree/master.svg?style=svg&circle-token=930b0a85da051123bf3f2c9c28ede5b29c607665)](https://circleci.com/gh/zabbix/zabbix-community-docker/tree/master) [![](https://badge.imagelayers.io/zabbix/zabbix-server-2.4:latest.svg)](https://imagelayers.io/?images=zabbix/zabbix-server-2.4:latest 'Get your own badge on imagelayers.io')

Compiled zabbix-server with almost all features (MySQL, Java, SNMP, Curl, Ipmi) 
and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. Image requires external 
MySQL database (you can run MySQL also as Docker container).

See [README of zabbix-server-2.4](https://github.com/zabbix/zabbix-community-docker/tree/master/Dockerfile/zabbix-server-2.4) for more details

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

How to build own Docker image
=============================

It's easy to build customized image on top of this base community image. 
You will need to specify only _FROM_ definition in your Dockerfile. For 
example: if you want to use always the latest available version, then please use:

```
FROM zabbix/zabbix-server-2.4:latest
```

Recommended example how to build custom Zabbix server on top of base image is 
[million12/docker-zabbix-server](https://github.com/million12/docker-zabbix-server). 
It provides custom features, such as Push notification, Slack and SMTP auth.  

About Docker
============

* [Official Docker Doc](https://docs.docker.com/)
* [Awesome Docker](https://github.com/veggiemonk/awesome-docker)
