# apache-tomcat-docker-dev
## Overview
I have developed a `Dockerfile` to build a custom Docker image for **Apache Tomcat v10.1.8**, (hereafter referred to just as *"Tomcat"*).

The image is customised with a Tomcat `server.xml` file that supports SSL using an accompanying custom keystore file.

With a little modification, the `Dockerfile` can be adapted to build a Docker image using newer versions of the base image, Apache Tomcat, the Java JDK, and an alternative `server.xml` and keystore.

This Docker image has been verified as working both standalone and in a Docker Swarm clustered set up.

## Prerequisites
Before using the `Dockerfile` to create a Docker image, you will need:

- [x] A host machine (preferably Linux) running a current version of Docker.

- [x] A user account on the host machine with the ability to run `docker` commands (this may require `sudo`).

- [x] The ability to download the **redhat/ubi8** base image to the host machine.

- [x] The accompanying keystore file `TOMkeystore.p12` uses a SAN (*Subject Alternative Name*) certificate for a test domain called `.domain12c.test`.  So, add an alias name in this domain to the `/etc/hosts` for your host machine, such as `machine1.domain12c.test`, as well as all the remote machines from which you intend to access the Tomcat instance from so that remote access is possible.   If you use a DNS server, update that server appropriately with the alias hostname.


## Docker Image Creation
First create a new directory on your host machine, such as `~/tomcat-build`.

Upload the following files and directories to this directory:

- `Dockerfile`
- `config/` directory and it's contents (replace these with your own custom versions if desired)
- `sample.war` - a sample application (optional).
- `apache-tomcat-10.1.8.tar.gz` - The Apache Tomcat binary distribution, downloadable from https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.8/bin/ (please observe the Apache license).
- `jdk-11.0.18_linux-x64_bin.tar.gz` - Oracle Java JDK v11, downloadable from https://www.oracle.com/uk/java/technologies/javase/jdk11-archive-downloads.html (please observe the Oracle license).

Once uploaded, change to the directory `~/tomcat-build`.  The directory listing should look something like the following:

```sh
$ ls
apache-tomcat-10.1.8.tar.gz  config  Dockerfile  jdk-11.0.18_linux-x64_bin.tar.gz sample.war
```

Pull the required base image **redhat/ubi8** with the command:

```sh
$ docker image pull redhat/ubi8
```

(Optional) Create a named Docker volume for later use by the container later, such as:
```sh
$ docker volume create tom-volume
```
(This can be used to access the container filesystem externally).

Make sure you are in the directory where the `Dockerfile` (and accompanying files) exist and build the Docker image using the command:

```sh
$ docker image build -t my-tomcat:v1.0 .
```
This will build a Docker image with the name and tag `my-tomcat:v1.0`, but you can choose a different name and tag if desired.

## Run a Container based on the Docker Image
Once the image has been created, you can run an interactive container based on it with a command such as the following:
```sh
$ docker run –it --name tom10 -p 8888:8080 -p 9443:8443 my-tomcat:v1.0
```
This assigns the name `tom10` to the running container, maps the exposed internal Tomcat ports 8080 and 8443 to the external ports 8888 and 8443 respectively, and starts an interactive session.

If you have assigned an alias of, say, `machine1.domain12.test` to your host machine, you can verify the Tomcat container is working by visiting the URLs:

- http://machine1.domain12c.test:8888/
- https://machine1.domain12c.test:9443/

You should see the classic Apache Tomcat front page; this also verifies that the port mappings are working.

Inside the interactive container session, you can run the Apache Tomcat shutdown script `shutdown.sh` to shutdown the Tomcat and stop the container.

## Background Notes
### Motivation
This is development project to explore the many capabilities available with `Dockerfile` commands when constructing a Docker image.

Also, by using a custom SAN (*Subject Alternative Name*) certificate for Tomcat instance's SSL configuration there is the added flexibility to easily deploy a large number of distinct Tomcat container instances from a  <ins>single</ins> image, all in the same DNS domain.  Such an image is therefore ideal for use in more complex clustered container deployments such as Docker Swarm or Kubernetes.


### Overview of the `Dockerfile`
In summary, the `Dockerfile` builds an image by doing the following: - 

1. Begins image creation with the base image **redhat/ubi8**.

2. Preconfigures the Tomcat startup option `$CATALINA_OPTS` with some custom setting, such as heap sizes `-Xms250m -Xmx500m`.

3. Installs Java JDK in the container image under `/opt/${JAVA_VERSION}` where `JAVA_VERSION=jdk-11.0.18`

4. Installs Apache Tomcat in the container image under `/opt/apache-tomcat-${TOMCAT_VERSION}` where `TOMCAT_VERSION=10.1.8`.

5. Configures the Tomcat `setenv.sh` script with necessary environment variables.

6. Copies a custom `server.xml` and keystore file `TOMkeystore.p12` to the Tomcat's `conf/` directory to support a custom SSL configuration.

7. Deploys a sample application `sample.war` to the Tomcat instance.

8. Declares that the container will listen on the Tomcat ports `8080` and `8443`.

9. Specifies the command to run the Tomcat instance.



### TO-DO
The `Dockerfile` can benefit from further improvements, including the following.

- Because of license and other restrictions with the the base image **redhat/ubi8**, using a different base image might be less restrictive.  
  
- Newer versions of Apache Tomcat and Java JDK.  Due to license restrictions with Oracle Java JDK, a different JDK (such as OpenJDK) might provide more flexibility.

- The `HEALTHCHECK` command in the `Dockerfile` needs further development, but this may depend on using a different base image.

- It may be more beneficial to use the `ENTRYPOINT` command to run the Tomcat instance in the container. This needs further investigation.

- Utilise the Docker volume to externally access parts of the container file system of interest, such as the Tomcat `logs/` directory.

- The Tomcat configuration could benefit from further security hardening.
