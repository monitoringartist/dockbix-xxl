[<img src="https://monitoringartist.github.io/managed-by-monitoringartist.png" alt="Managed by Monitoring Artist: DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring" align="right"/>](http://www.monitoringartist.com 'DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring')

# Dockbix XXL

[Dockbix XXL](https://github.com/monitoringartist/dockbix-xxl) is a standard Zabbix preconfigured for Docker world and out of the box Docker monitoring o. This Docker image contains standard Zabbix + additional XXL (community) extensions. Routine tasks are included: import of Zabbix DB, import of Docker monitoring template, autoregistration rule of Dockbix agents, ...

If you like or use this project, please provide feedback to author - Star it ★.

----

**Overview of Monitoring Artist (dockerized) monitoring ecosystem:**

- **[Dockbix XXL](https://hub.docker.com/r/monitoringartist/dockbix-xxl/)** - standard Zabbix preconfigured for Docker monitoring with additional XXL extensions
- **[Dockbix agent XXL](https://hub.docker.com/r/monitoringartist/dockbix-agent-xxl-limited/)** - Zabbix agent with [Docker (Kubernetes/Mesos/Chronos/Marathon) monitoring](https://github.com/monitoringartist/zabbix-docker-monitoring)
- **[Zabbix templates](https://hub.docker.com/r/monitoringartist/zabbix-templates/)** - tiny (5MB) image for easy template deployment of selected Zabbix monitoring templates
- **[Zabbix extension - all templates](https://hub.docker.com/r/monitoringartist/zabbix-ext-all-templates/)** - storage image for Zabbix XXL with 200+ [community templates](https://github.com/monitoringartist/zabbix-community-repos)
- **[Kubernetized Zabbix](https://github.com/monitoringartist/kubernetes-zabbix)** - containerized Zabbix cluster based on Kubernetes
- **[Grafana XXL](https://hub.docker.com/r/monitoringartist/grafana-xxl/)** - dockerized Grafana with all community plugins
- **[Grafana dashboards](https://grafana.net/monitoringartist)** - Grafana dashboard collection for [AWS](https://github.com/monitoringartist/grafana-aws-cloudwatch-dashboards) and [Zabbix](https://github.com/monitoringartist/grafana-zabbix-dashboards)
- **[Monitoring Analytics](https://hub.docker.com/r/monitoringartist/monitoring-analytics/)** - R statistical computing and graphics for monitoring from data scientists
- **[Docker killer](https://hub.docker.com/r/monitoringartist/docker-killer/)** - Docker image for Docker stress and Docker orchestration testing

----

# Quick start

```bash
docker run \
    -d \
    --name zabbix-db \
    --env="MARIADB_USER=zabbix" \
    --env="MARIADB_PASS=my_password" \
    monitoringartist/zabbix-db-mariadb
```

This DB container requires 1GB of memory by default. See [README of zabbix-db-mariadb](https://github.com/monitoringartist/dockbix-xxl/tree/master/Dockerfile/zabbix-db-mariadb)
for more details and configurable options via environment variables.

# Configuration

# Support / issues

This project support only issues related to this Docker image.


# Legacy Docker images

Previous versions of current Docbix XXL image:

### 1. [Docker image zabbix-xxl (Zabbix 3.0/3.2)](https://hub.docker.com/r/monitoringartist/zabbix-xxl/)

See [README of zabbix-xxl](https://github.com/monitoringartist/dockbix-xxl/tree/master/Dockerfile/zabbix-xxl) for more details.

Compiled Zabbix (server, proxy, agent, java gateway, snmpd daemon) with almost all features (MySQL support, Java, SNMP, Curl, Ipmi, SSH, fping) and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. Image requires external MySQL/MariDB database (you can run MySQL/MariaDB as a Docker container). Integated XXL extensions: Searcher, Grapher, Zapix, template auto import, API command/script execution.


### 2. [Docker image zabbix-2.4](https://registry.hub.docker.com/u/monitoringartist/zabbix-2.4/)

See [README of zabbix-2.4](https://github.com/monitoringartist/dockbix-xxl/tree/master/Dockerfile/zabbix-2.4)
for more details.

Compiled Zabbix with almost all features (MySQL support, Java, SNMP, 
Curl, Ipmi, fping) and Zabbix web UI based on CentOS 7, Supervisor, Nginx, PHP. 
Image requires external MySQL database (you can run MySQL also as Docker 
container).

# Docker troubleshooting

Use docker command to see if all required containers are up and running: 

```bash
docker ps -f
```

Check online logs of Zabbix container:

```bash
docker logs zabbix
```

Sometimes you might just want to review how things are deployed inside a running
 container, you can do this by executing a _bash shell_ through _docker's 
 exec_ command:
  
```bash
docker exec -ti zabbix /bin/bash
```

Run specific Zabbix version, e.g. 3.4.0 - just specify 3.4.0 tag for image:

```bash
	docker run -d \
		--name dockbix \
		-p 80:80 \
		-p 10051:10051 \
    -v /etc/localtime:/etc/localtime:ro \
		-e "ZS_DBHost=database_ip" \
		-e "ZS_DBUser=username" \
		-e "ZS_DBPassword=my_password" \
		monitoringartist/dockbix-xxl:3.4.0
```

# Legacy images

Project contains specification for legacy images:

monitoringartist/zabbix-xxl
monitoringartist/zabbix-server-3.0

It's no recommended to use them in the production.

# Author

[Devops Monitoring Expert](http://www.jangaraj.com 'DevOps / Docker / Kubernetes / AWS ECS / Google GCP / Zabbix / Zenoss / Terraform / Monitoring'),
who loves monitoring systems and cutting/bleeding edge technologies: Docker,
Kubernetes, ECS, AWS, Google GCP, Terraform, Lambda, Zabbix, Grafana, Elasticsearch,
Kibana, Prometheus, Sysdig, ...

Summary:
* 2000+ [GitHub](https://github.com/monitoringartist/) stars
* 10 000+ [Grafana dashboard](https://grafana.net/monitoringartist) downloads
* 1 000 000+ [Docker image](https://hub.docker.com/u/monitoringartist/) pulls

Professional devops / monitoring / consulting services:

[![Monitoring Artist](http://monitoringartist.com/img/github-monitoring-artist-logo.jpg)](http://www.monitoringartist.com 'DevOps / Docker / Kubernetes / AWS ECS / Google GCP / Zabbix / Zenoss / Terraform / Monitoring')
