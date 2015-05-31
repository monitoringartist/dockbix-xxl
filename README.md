Zabbix Community Dockerfiles
============================

[Github repo](https://github.com/zabbix/zabbix-community-docker is intended
 as source for [Zabbix Docker registry](https://registry.hub.docker.com/repos/zabbix/).
Please use these community Zabbix Docker images, if you want to [build/ship your own image](#how-to-build-own-docker-image).

Available images
================

1. zabbix-server (2.4)

Compiled zabbix-server with almost all features (MySQL, Java, SNMP, Curl, Ipmi)
base on CentOS 7 and Supervisor. Image requires external MySQL database
(you can run MySQL also as Docker container).

#### Zabbix database as Docker container
To be able to connect to database we would need one to be running first. 
Easiest way to do that is to use another docker image. 
For this purpose you can use [million12/mariadb](https://registry.hub.docker.com/u/million12/mariadb/)
 image as our database.

**For more information about million12/MariaDB see [documentation.](https://github.com/million12/docker-mariadb) **

Example:  

	docker run \
		-d \
		--name zabbix-db \
		-p 3306:3306 \
		--env="MARIADB_USER=username" \
		--env="MARIADB_PASS=my_password" \
		million12/mariadb

***Remember to use the same credentials when deploying zabbix-server image.***


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

#### Troubleshooting
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
Sometimes you might just want to review how things are deployed inside a container, you can do this by executing a _bash shell_ through _docker's exec_ command:
```
docker exec -i -t zabbix-exploring /bin/bash
```

How to build own Docker image
=============================

It's easy to build customized image on top of this base community image. 
You will need to specify only FROM definition in your Dockerfile. For 
example: if you want to use always the latest available version, then please use:

```
FROM zabbix/zabbix-server-2.4:latest
```

Recommended example how to build custom Zabbix server on top of base image is 
[repo million12/docker-zabbix-server](https://github.com/million12/docker-zabbix-server). 
It provides custom features, such as Push notification, Slack and SMTP auth.  

About Docker
============

See [Awesome Docker](https://github.com/veggiemonk/awesome-docker)
