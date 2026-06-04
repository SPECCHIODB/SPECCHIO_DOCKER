# [WIP] Docker Solution for SPECCHIO

This repository contains a dockerized deployment solution for the SPECCHIO database. This architecture enables users to rapidly instantiate a complete local environment with significantly reduced resource consumption compared to legacy Virtual Machine (VM) implementations.

While optimized for local development, this configuration can be adapted for production public instances with minor environmental adjustments.

---

## Deployment Instructions

### 1. Prerequisites

Ensure that Docker is installed and active on your host system.

* **Installation Documentation:** Refer to the [Docker Desktop Installation Guide](https://docs.docker.com/desktop/).
* **Service Activation:** On most Unix-based operating systems, initialize the daemon via:
```bash
sudo systemctl start docker

```



### 2. Repository Extraction

Clone or copy the target configuration folder from the `/compose` directory of this repository to your local workspace.

> **Note:** Multiple deployment profiles will be supported in future releases. Currently, the `clean_install` profile is available.

```bash
cp -r /path/to/repo/compose/clean_install /desired/local/path/

```

### 3. Environment Configuration

Review and modify the configuration parameters within the respective `Dockerfile` or environment definitions if custom port mappings or volume mounts are required. Configuration options are documented directly within the files.

### 4. Service Initialization

Deploy the multi-container stack in detached mode by executing the following command from the directory containing your `docker-compose.yml` file:

```bash
docker compose up -d

```

This initializes the three decoupled application containers and their isolated virtual network.

* **Log Verification:** To inspect runtime output for troubleshooting, execute:
```bash
docker compose logs <container_name>

```



### 5. SSL Certificate Trust Configuration

To establish a trusted HTTPS connection between your local Java client and the SPECCHIO container instance, you must import the generated self-signed certificates into your Java Development Kit (JDK) truststore. Execute the automated utility script provided:

```bash
./java_local_cert_update.sh

```

### 6. Client Connection Verification

Launch your SPECCHIO client application and verify connectivity to the server using the configuration parameters detailed below:

| Parameter | Recommended Value |
| --- | --- |
| **Web Application Server** | `localhost` |
| **Port** | `443` |
| **Application Path** | `/specchio` |
| **Data Source Name** | `jdbc/specchio` |
| **SSL Enforcement** | **ENABLE** "Use default JVM trust store" |

### 7. Administrative Console Access

The server application management interface is bound strictly to the loopback address due to security policies. It cannot be accessed via the `localhost` hostname.

* **Administrative URL:** `http://127.0.0.1:4848`

---

## Repository Architecture

```
├── compose  
│   └── clean_install
│       ├── db
│       │   └── init-db
│       │       ├── 01_SPECCHIO_V3.3.4.sql
│       │       ├── 02_sdb_admin_creation_docker.sql
│       │       ├── 03_specchio_database_upgrade_V3.3.4_V3.3.5.sql
│       │       ├── 04_specchio_database_upgrade_V3.3.5_V3.3.6.sql
│       │       └── 05_specchio_database_upgrade_V3.3.6_V3.3.7.sql
│       ├── db_storage 
│       ├── docker-compose.yml
│       └── nginx
│           ├── nginx.conf
│           └── ssl
│               ├── server.crt
│               └── server.key
└── webapp
    ├── Dockerfile
    ├── entrypoint.sh
    ├── mysql-connector-java-5.1.47-bin.jar
    └── push_dockerhub.sh

```

### `/compose` Directory

This directory houses the orchestration assets needed to provision the infrastructure stack. The behavior is driven by the `docker-compose.yml` manifest.

* **`clean_install`:** Instantiates a greenfield SPECCHIO database from an empty state. Future iterations will include migration tracks for existing deployments.
* **`./db/init-db`:** This entrypoint directory is parsed **exclusively during the initial container startup**, provided that the `./db/db_storage` volume is uninitialized. Initialization scripts are executed in alphanumeric sequence to bootstrap the schema up to the latest release version.
* **`./db/db_storage`:** Serves as the persistent host-volume mount point for the database container's internal storage engine, ensuring data longevity across container lifecycles.
* **`./nginx/nginx.conf`:** Configuration manifest for the Nginx reverse proxy. It orchestrates HTTP/HTTPS traffic routing, SSL termination, and proxy headers for the underlying web application. This file requires no modification for standard deployments.
* **`./nginx/ssl`:** Secure directory containing cryptographic assets. Includes self-signed certificates for local loopback verification, which can be replaced with public Authority certificates (e.g., Let's Encrypt) for production domains.
* **`java_local_cert_update.sh`:** A helper script designed to automate the injection of the local self-signed HTTPS certificates into the active JVM truststore.

### `/webapp` Directory

This directory contains the source configuration for building the bespoke SPECCHIO enterprise web application container image.

* **`Dockerfile`:** Defines the layered build process, using an Ubuntu base image compiled with the precise versions of the OpenJDK runtime environment and the GlassFish application server required by the software layer.
* **`entrypoint.sh` & `mysql-connector-java-5.1.47-bin.jar`:** Core runtime initialization assets utilized during the image compilation process. These files should remain unmodified under typical maintenance workflows.