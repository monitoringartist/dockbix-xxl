# MariaDB 10.0 Docker Image (Centos7)
[![Circle CI](https://circleci.com/gh/million12/docker-mariadb.svg?style=svg)](https://circleci.com/gh/million12/docker-mariadb)

This is a MariaDB 10.0 Docker [million12/mariadb](https://registry.hub.docker.com/u/million12/mariadb/) image. Built on top of official [centos:centos7](https://registry.hub.docker.com/_/centos/) image. Inspired by [Tutum](https://github.com/tutumcloud)'s [tutum/mariadb](https://github.com/tutumcloud/tutum-docker-mariadb) image.

Note: be aware that, by default in this container, MariaDB is configured to use 1GB memory (innodb_buffer_pool_size in [tuning.cnf](container-files/etc/my.cnf.d/tuning.cnf)). If you try to run it on node with less memory, it will fail.

## Usage

`docker pull million12/mariadb`

Or, if you prefer to build it on your own:  
`docker build -t million12/mariadb .`

Run the image as daemon and bind it to port 3306:  
`docker run -d -p 3306:3306 million12/mariadb`

The first time that you run your container, a new user admin with all privileges will be created in MariaDB with a random password. To get the password, check the logs of the container by running:  
`docker logs <CONTAINER_ID>`  

You will see an output like the following:

```
	========================================================================
    You can now connect to this MariaDB Server using:

        mysql -uadmin -pCoFlnc3ZBS58 -h<host>

    Please remember to change the above password as soon as possible!       
    MariaDB user 'root' has no password but only allows local connections
    ========================================================================
```  
In this case, `CoFlnc3ZBS58` is the password assigned to the `admin` user.

### Custom Password for user admin 
If you want to use a preset password instead of a random generated one, you can set the environment variable MARIADB_PASS to your specific password when running the container:  

`docker run -d -p 3306:3306 -e MARIADB_PASS="mypass" million12/mariadb`

### Mounting the database file volume from other containers
One way to persist the database data is to store database files in another container. To do so, first create a container that holds database files:  

`docker run -d -v /var/lib/mysql --name db-data busybox:latest`  

This will create a new container and use its folder `/var/lib/mysql` to store MariaDB database files. You can specify any name of the container by using `--name` option, which will be used in next step.

After this you can start your MariaDB image using volumes in the container created above (put the name of container in `--volumes-from`).  

`docker run -d --volumes-from db-data -p 3306:3306 million12/mariadb`

## Authors

Author: Marcin Ryzycki (<marcin@m12.io>)  
Author: Przemyslaw Ozgo (<linux@ozgo.info>)  

---

**Sponsored by** [Typostrap.io - the new prototyping tool](http://typostrap.io/) for building highly-interactive prototypes of your website or web app. Built on top of TYPO3 Neos CMS and Zurb Foundation framework.
