# [WIP] Docker Solution for Specchio

This repository provides a dockerized solution for the SPECCHIO database. 
This enables users to easily run a full local instance with a few clicks and less resources than the older VM solution. 

At the same time, the same system may be used for public instances, with only minor edits that need to be made for them to run. 

# Run the Dockerized SPECCHIO DB

1. Ensure, you have Docker on your system and that docker is running. 
    - Install guides: https://docs.docker.com/desktop/
    - Start Docker: `sudo systemctl start docker` (for most UNIX systems)

2. Copy or tclone he `/compose/... ` folder from this repo (there will be different use cases, for now it's just `clean_install`). 

3. bring the folder to the desired location on your machine

4. Check if you want to edit any properties in the Dockerfile(ports, mapped folders etc). Options are described directly in the Dockerfile

5. Run the compose (`docker compose up -d`). The three containers and the network will start
    - if you want to check the logs of a container: use `docker compose logs containername`  

6. To make your java client trust the local instance with a HTTPS certificate, we need to add the cretated certificates to the JDK truststore. To do so, run the `java_local_cert_update.sh`script. 

7. Ensure your SPECCHIO Docker instance is working by starting up the client and check if you can connect to the server. The following parameters should be used: 
```
Web Application Server: localhost 
Port: 443
Application Path: /specchio
Data Source Name: jdbc/specchio

ENABLE "Use default JVM trust store"
```

8. If you need to access the server's admin console, you can access it ONLY via 127.0.0.1:4848 (localhost is banned)


# Code Structure
```
├── compose  
│   └── clean_install
│       ├── db
│       │   └── init-db
│       │       ├── 01_SPECCHIO_V3.3.4.sql
│       │       ├── 02_sdb_admin_creation_docker.sql
│       │       ├── 03_specchio_database_upgrade_V3.3.4_V3.3.5.sql
│       │       ├── 04_specchio_database_upgrade_V3.3.5_V3.3.6.sql
│       │       └── 05_specchio_database_upgrade_V3.3.6_V3.3.7.sql
│       ├── db_storage 
│       │  
│       ├── docker-compose.yml
│       └── nginx
│           ├── nginx.conf
│           └── ssl
│               ├── server.crt
│               └── server.key
└── webapp
    ├── Dockerfile
    ├── entrypoint.sh
    ├── mysql-connector-java-5.1.47-bin.jar
    └── push_dockerhub.sh
```

## Compose 
This part is used to run an instance of the dockerized system. Its key element is always the Dockerfile. For now only a `clean_install` variant extists, which starts a new Specchio from zero. Further versions will be available to migrate existing instances to Docker etc.

The structure contains two subfolders for the db and nginx containers. 

- `./db/init-db`: is read at only at **the first startup** of the dockerized system (this is the case if db_storage is found empty). The files in this folder are read alphabetically. At the end the db is fully initialized to the current version. 

- `./db/db_storage`: Primary data storage folder for the db. This is mapped to the db folder inside the container (to make that persistent).


- `./nginx/nginx.conf` : Config file for the nginx reverse proxy. This ensures proper HTTP and HTTPS access to the webapp and rules certificates etc. Can be left untouched for most use cases 

- `./nginx/ssl` : Folder for all certificates: local, self-signed ones to access a small instance locally with HTTPS and Let's Encrypt certs fr public instances with a proper URL.

- `java_local_cert_update.sh`: script to copy the self-signed certificates for localhost HTTPS access to the JVM trust store. 




## Webapp 

This part is to build the custom Webapp container. It bases on an Ubuntu machine and adds JDK and GlassFish versions that do fit the needs of the webapp.
key element is the `Dockerfile`, which is used to build a new version of the container. 

`entrypoint.sh` and `mysql-connector-java-5.1.47-bin.jar`are both used for the container build, and should be left untouched usually. 

