Zabbix XXL
==========

[Zabbix XXL](https://github.com/monitoringartist/zabbix-server-xxl-docker) is a standard Zabbix prepared for Docker world. You must install Zabbix package (rpm, deb, ...) in the old world. Similarly you need to pull Zabbix Docker image in the Docker world. This Docker image contains standard Zabbix + additional XXL (community) extensions. Routine tasks such as import of Zabbix DB are automated, so it's prepared for easy deployment.

If you like or use this project, please provide feedback to author - Star it ★.

**Overview of Monitoring Artist (dockerized) monitoring ecosystem:**

- **[Zabbix XXL](https://hub.docker.com/r/monitoringartist/zabbix-xxl/)** - standard Zabbix 3.x server/proxy/UI/snmpd/java gateway with additional XXL extensions
- **[Zabbix agent XXL](https://hub.docker.com/r/monitoringartist/zabbix-agent-xxl-limited/)** - Zabbix 3.0 agent with [Docker (Mesos/Chronos/Marathon) monitoring](https://github.com/monitoringartist/zabbix-docker-monitoring) and [systemd monitoring](https://github.com/monitoringartist/zabbix-systemd-monitoring)
- **[Zabbix templates](https://hub.docker.com/r/monitoringartist/zabbix-templates/)** - tiny (5MB) image for easy template deployment of selected Zabbix monitoring templates
- **[Zabbix extension - all templates](https://hub.docker.com/r/monitoringartist/zabbix-ext-all-templates/)** - storage image for Zabbix XXL with 200+ [community templates](https://github.com/monitoringartist/zabbix-community-repos)
- **[Kubernetized Zabbix](https://github.com/monitoringartist/kubernetes-zabbix)** - containerized Zabbix cluster based on Kubernetes
- **[Grafana XXL](https://hub.docker.com/r/monitoringartist/grafana-xxl/)** - dockerized Grafana with all community plugins
- **[Grafana dashboards](https://grafana.net/monitoringartist)** - Grafana dashboard collection for [AWS](https://github.com/monitoringartist/grafana-aws-cloudwatch-dashboards) and [Zabbix](https://github.com/monitoringartist/grafana-zabbix-dashboards)
- **[Monitoring Analytics](https://hub.docker.com/r/monitoringartist/monitoring-analytics/)** - R statistical computing and graphics for monitoring from data scientists
- **[Docker killer](https://hub.docker.com/r/monitoringartist/docker-killer/)** - Docker image for Docker stress and Docker orchestration testing

Available Docker images
=======================

### 1. [Docker image zabbix-xxl (Zabbix 3.x)](https://hub.docker.com/r/monitoringartist/zabbix-xxl/) [![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-xxl/) [![](https://badge.imagelayers.io/monitoringartist/zabbix-xxl:latest.svg)](https://imagelayers.io/?images=monitoringartist/zabbix-xxl:latest)

See [README of zabbix-xxl](https://github.com/monitoringartist/zabbix-xxl/tree/master/Dockerfile/zabbix-xxl) for more details.

Compiled Zabbix (server, proxy, agent, java gateway, snmpd daemon) with almost all features (MySQL support, Java, SNMP, Curl, Ipmi, SSH, fping) and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. Image requires external MySQL/MariDB database (you can run MySQL/MariaDB as a Docker container). Integated XXL extensions: Searcher, Grapher, Zapix, template auto import, API command/script execution.

![Zabbix XXL Zabbix searcher](https://raw.githubusercontent.com/monitoringartist/zabbix-xxl/master/doc/zabbix-3.0-xxl-zabbix-searcher.png)

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
docker history --no-trunc=true monitoringartist/zabbix-xxl | tr -s ' ' | tail -n+2 | awk -F " ago " '{print $2}'
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
		monitoringartist/zabbix-xxl:3.0.3
```

Customized Zabbix Docker images
===============================

Recommended example how to build custom Zabbix server on top of base image is 
[million12/docker-zabbix-server](https://github.com/million12/docker-zabbix-server). 
It provides custom features, such as Push notification, Slack and SMTP auth.

Support
=======

Public Docker image monitoringartist/zabbix-xxl has best effort support.
Please contact info@monitoringartist.com for commercial support.

Security issues
===============

Our Docker images are security scanned regularly. All detected vulnerabilities are fixed*:

- Critical vulnerabilities - within 72 hours of notification
- Major vulnerabilities - within 7 days of notification

*except Zabbix security issues, which will be reported directly to Zabbix vendor  

Related Zabbix Docker projects
==============================

* [Zabbix agent 3.0 XXL with Docker monitoring support](https://github.com/monitoringartist/zabbix-agent-xxl)
* Dockerized project [Grafana XXL](https://github.com/monitoringartist/grafana-xxl), which includes also [Grafana Zabbix datasource](https://github.com/alexanderzobnin/grafana-zabbix)
* Scale your Dockerized [Zabbix with Kubernetes](https://github.com/monitoringartist/kubernetes-zabbix)

About Docker
============

* [Official Docker Doc](https://docs.docker.com/)
* [Awesome Docker](http://veggiemonk.github.io/awesome-docker/)

# Author

[Devops Monitoring Expert](http://www.jangaraj.com 'DevOps / Docker / Kubernetes / AWS ECS / Google GCP / Zabbix / Zenoss / Terraform / Monitoring'),
who loves monitoring systems and cutting/bleeding edge technologies: Docker,
Kubernetes, ECS, AWS, Google GCP, Terraform, Lambda, Zabbix, Grafana, Elasticsearch,
Kibana, Prometheus, Sysdig, ...

Summary:
* 1000+ [GitHub](https://github.com/monitoringartist/) stars
* 6000+ [Grafana dashboard](https://grafana.net/monitoringartist) downloads
* 800 000+ [Docker image](https://hub.docker.com/u/monitoringartist/) pulls

Professional devops / monitoring / consulting services:

[![Monitoring Artist](http://monitoringartist.com/img/github-monitoring-artist-logo.jpg)](http://www.monitoringartist.com 'DevOps / Docker / Kubernetes / AWS ECS / Google GCP / Zabbix / Zenoss / Terraform / Monitoring')
