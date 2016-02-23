Zabbix Community Dockerfiles
============================

[Zabbix Github repo](https://github.com/zabbix/zabbix-community-docker) is intended as a source for [Zabbix Docker registry](https://hub.docker.com/u/zabbix/). Please use these community Zabbix Docker images, if you want to [build/ship your own Zabbix Docker image](https://github.com/zabbix/zabbix-community-docker#how-to-build-own-docker-image).

Available Docker images
=======================

### 1. [Docker image zabbix-3.0](https://registry.hub.docker.com/u/zabbix/zabbix-3.0/) [![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/zabbix/zabbix-community-docker/tree/master/Dockerfile/zabbix-3.0/) [![](https://badge.imagelayers.io/zabbix/zabbix-3.0:dev.svg)](https://imagelayers.io/?images=zabbix/zabbix-3.0:dev)

See [README of zabbix-3.0](https://github.com/zabbix/zabbix-community-docker/tree/master/Dockerfile/zabbix-3.0)
for more details.

Compiled Zabbix with almost all features (MySQL support, Java, SNMP, Curl, Ipmi, 
fping) and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. Image 
requires external MySQL database (you can run MySQL also as Docker container).

### 2. [Docker image zabbix-db-mariadb](https://registry.hub.docker.com/u/zabbix/zabbix-db-mariadb/) [![](https://badge.imagelayers.io/zabbix/zabbix-db-mariadb:latest.svg)](https://imagelayers.io/?images=zabbix/zabbix-db-mariadb:latest)

See [README of zabbix-db-mariadb](https://github.com/zabbix/zabbix-community-docker/tree/master/Dockerfile/zabbix-db-mariadb) 
for more details.

MariaDB container customized for Zabbix.

### 3. [Docker image zabbix-2.4](https://registry.hub.docker.com/u/zabbix/zabbix-2.4/) [![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/zabbix/zabbix-community-docker/tree/master/Dockerfile/zabbix-2.4/) [![](https://badge.imagelayers.io/zabbix/zabbix-2.4:latest.svg)](https://imagelayers.io/?images=zabbix/zabbix-2.4:latest)

**2.4 is not supported version** - please use 3.0 version.

See [README of zabbix-2.4](https://github.com/zabbix/zabbix-community-docker/tree/master/Dockerfile/zabbix-2.4) 
for more details.

Compiled Zabbix with almost all features (MySQL support, Java, SNMP, 
Curl, Ipmi, fping) and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. 
Image requires external MySQL database (you can run MySQL also as Docker 
container).


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
		--env="ZS_DBHost=database_ip" \
		--env="ZS_DBUser=username" \
		--env="ZS_DBPassword=my_password" \
		zabbix/zabbix-3.0:3.0.0
```

How to build own Docker image
=============================

It's easy to build customized image on top of this base community image. 
You will need to specify only _FROM_ definition in your Dockerfile. For 
example: if you want to use always the latest available version, then please use:

```
FROM zabbix/zabbix-3.0:latest
```

Customized Zabbix Docker images
===============================

Recommended example how to build custom Zabbix server on top of base image is 
[million12/docker-zabbix-server](https://github.com/million12/docker-zabbix-server). 
It provides custom features, such as Push notification, Slack and SMTP auth.  

Related Zabbix Docker projects
==============================

* [Zabbix agent 3.0 XXL with Docker monitoring support](https://github.com/monitoringartist/zabbix-agent-xxl)
* Dockerised project [Grafana XXL](https://github.com/monitoringartist/grafana-xxl), which includes also [Grafana Zabbix datasource](https://github.com/alexanderzobnin/grafana-zabbix)
* Scale your Dockerised [Zabbix with Kubernetes](https://github.com/monitoringartist/kubernetes-zabbix)

About Docker
============

* [Official Docker Doc](https://docs.docker.com/)
* [Awesome Docker](http://getawesomeness.com/get/docker)
