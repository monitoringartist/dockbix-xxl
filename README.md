Zabbix XXL
==========

[Zabbix XXL repo](https://github.com/monitoringartist/zabbix-server-xxl-docker) is intended as a source of some [Zabbix Docker images](https://hub.docker.com/u/monitoringartist/dashboard/). It contains standard Zabbix + additional XXL (community) extensions and everything is packaged into Docker image for easy deployment.

Available Docker images
=======================

### 1. [Docker image zabbix-3.0-xxl](https://hub.docker.com/r/monitoringartist/zabbix-3.0-xxl/) [![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-3.0/) [![](https://badge.imagelayers.io/monitoringartist/zabbix-3.0-xxl:latest.svg)](https://imagelayers.io/?images=monitoringartist/zabbix-3.0-xxl:latest)

See [README of zabbix-3.0-xxl](https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-3.0) for more details.

Compiled Zabbix (server, proxy, agent, java gateway, snmpd daemon) with almost all features (MySQL support, Java, SNMP, Curl, Ipmi, SSH, fping) and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. Image requires external MySQL/MariDB database (you can run MySQL/MariaDB as a Docker container). Integated XXL extensions: Searcher, Grapher (beta), Zapix (beta).

### 2. [Docker image zabbix-db-mariadb](https://registry.hub.docker.com/u/monitoringartist/zabbix-db-mariadb/) [![](https://badge.imagelayers.io/monitoringartist/zabbix-db-mariadb:latest.svg)](https://imagelayers.io/?images=monitoringartist/zabbix-db-mariadb:latest)

See [README of zabbix-db-mariadb](https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-db-mariadb) 
for more details.

MariaDB container customized for Zabbix.

### 3. [Docker image zabbix-2.4](https://registry.hub.docker.com/u/monitoringartist/zabbix-2.4/) [![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-2.4/) [![](https://badge.imagelayers.io/monitoringartist/zabbix-2.4:latest.svg)](https://imagelayers.io/?images=monitoringartist/zabbix-2.4:latest)

**2.4 is not supported version** - please use 3.0 version.

See [README of zabbix-2.4](https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-2.4) 
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
docker history --no-trunc=true monitoringartist/zabbix-3.0-xxl | tr -s ' ' | tail -n+2 | awk -F " ago " '{print $2}'
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
		monitoringartist/zabbix-3.0-xxl:3.0.3
```

How to build own Docker image
=============================

It's easy to build customized image on top of this base image. 
You will need to specify only _FROM_ definition in your Dockerfile. For 
example: if you want to use always the latest available version, then please use:

```
FROM monitoringartist/zabbix-3.0-xxl:latest
```

Customized Zabbix Docker images
===============================

Recommended example how to build custom Zabbix server on top of base image is 
[million12/docker-zabbix-server](https://github.com/million12/docker-zabbix-server). 
It provides custom features, such as Push notification, Slack and SMTP auth.

Support
=======

Public Docker image monitoringartist/zabbix-3.0-xxl has best effort support.

Security issues
===============

Our zabbix Docker images are security scanned regularly. All detected vulnerabilities are fixed*:

- Critical vulnerabilities - within 72 hours of notification
- Major vulnerabilities - within 7 days of notification

*except Zabbix security issues, which will be reported directly to Zabbix vendor  

Related Zabbix Docker projects
==============================

* [Zabbix agent 3.0 XXL with Docker monitoring support](https://github.com/monitoringartist/zabbix-agent-xxl)
* Dockerised project [Grafana XXL](https://github.com/monitoringartist/grafana-xxl), which includes also [Grafana Zabbix datasource](https://github.com/alexanderzobnin/grafana-zabbix)
* Scale your Dockerised [Zabbix with Kubernetes](https://github.com/monitoringartist/kubernetes-zabbix)

About Docker
============

* [Official Docker Doc](https://docs.docker.com/)
* [Awesome Docker](http://veggiemonk.github.io/awesome-docker/)

Author
======

[Devops Monitoring Expert](http://www.jangaraj.com 'DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring'),
who loves monitoring systems, which start with letter Z. Those are Zabbix and Zenoss.

Professional devops / monitoring services:

[![Monitoring Artist](http://monitoringartist.com/img/github-monitoring-artist-logo.jpg)]
(http://www.monitoringartist.com 'DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring')

