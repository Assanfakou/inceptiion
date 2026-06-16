*This project has been created as part of the 42 curriculum by hfakou.*

# Inception

## Description

Inception is a system administration project from the 42 school curriculum. The goal is to set up a small but complete web infrastructure using Docker and Docker Compose, where each service runs in its own dedicated container. No pre-built images from Docker Hub are used — every container is built from a custom Dockerfile based on Debian.

The stack includes a WordPress site served through an NGINX reverse proxy with TLS, backed by a MariaDB database, accelerated by Redis cache, and extended with bonus services: Adminer for database management, an FTP server for file access, a static personal site, and Portainer for container management.

## Instructions

### Prerequisites

- Make sure to go to the `/etc/hosts/` with sudo.
- Change the localhost with the login.42.fr.

### 1. Set up environment variables

Create a `srcs/.env` file at the root of the `srcs/` directory and define the following variables:

```env
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
DB_HOST=
WP_URL=
WP_USER_ADMIN=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=
WP_USER=
WP_USER_EMAIL=
WP_USER_PASSWORD=
FTP_USER=
FTP_PASSWORD=
```


### 2. Build and run

```bash
make all      # create data directories, build all images, and start the stack
make up       # start containers without rebuilding
make down     # stop the stack
make clean    # stop the stack and remove containers, networks, volumes, and local data
make status   # check the status of running containers
make logs     # follow live service logs
```

### 3. Access the services

| Service | URL |
|---|---|
| WordPress site | `https://hfakou.42.fr` |
| WordPress admin | `https://hfakou.42.fr/wp-admin/` |
| Adminer | `https://hfakou.42.fr/adminer/` |
| Static site | `https://hfakou.42.fr/static/` |
| Portainer | `https://hfakou.42.fr/portainer/` |
| FTP | `ftp hfakou.42.fr` |

SSL certificates are self-signed — accept the browser warning on first access.

---

## Project Description

### Docker and Services Overview

This project uses Docker to isolate each service in its own container, controlling dependencies and enabling repeatable deployment. All containers are defined in `srcs/docker-compose.yml` and built from Dockerfiles located in `srcs/requirements/`.

The services included are:

- **NGINX** — SSL/TLS reverse proxy and the sole public entry-point (port 443)
- **WordPress** — PHP-FPM application, communicates with MariaDB and Redis
- **MariaDB** — relational database storing all WordPress data
- **Redis** — in-memory cache that reduces database load and speeds up WordPress
- **Adminer** — lightweight browser-based interface for managing the MariaDB database
- **FTP** — file transfer server giving direct access to the WordPress root directory
- **Static Site** — a simple personal portfolio page served as a bonus
- **Portainer** — web UI for monitoring and managing Docker containers and volumes

All containers communicate over a user-defined Docker network called `inception`, which allows them to resolve each other by service name without hard-coded IPs. Persistent data (WordPress files and MariaDB data) is stored on Docker volumes bound to the host filesystem under `/home/hfakou/data`, so content and database records survive container restarts.

---

### Design Choices

#### Virtual Machines vs Docker

Virtual Machines run a full guest operating system on top of a hypervisor, providing strong isolation and the ability to run different kernels. However, they are heavy: each VM consumes significant memory, storage, and boot time.

Docker containers share the host kernel and start in milliseconds. They are far lighter and easier to manage for a multi-service web stack like this one. For a project focused on service orchestration and networking, Docker is the more practical and efficient choice.

#### Secrets vs Environment Variables

Environment variables (defined in `srcs/.env`) are used throughout this project for database credentials, WordPress settings, and FTP access. They are simple to configure with Docker Compose and sufficient for a development environment.

Docker Secrets are the preferred approach for production deployments. They store sensitive values outside the container environment, expose them only to the services that need them, and integrate with orchestration platforms like Docker Swarm. For this project, the `.env` file is kept out of version control as a minimum precaution.

#### Docker Network vs Host Network

This project uses a user-defined bridge network (`inception`). Containers on this network can reach each other by service name (e.g., `wordpress` can connect to `mariadb` simply by hostname), while remaining isolated from other processes running on the host.

Host network mode removes that isolation — containers share the host's network stack directly, which can create port conflicts and reduce security. For a stack where services only need to talk to each other and be reachable through NGINX, the bridge network is cleaner and safer.

#### Docker Volumes vs Bind Mounts

This project uses Docker volumes configured with bind mount options, storing data in specific host directories (`~/data/wordpress` and `~/data/mariadb`). This gives explicit control over where data lives while keeping it outside the container lifecycle.

Pure bind mounts expose a host directory directly into a container without going through Docker's volume management, which can be convenient in development but less portable across environments. The current approach combines the reliability of Docker volumes with the visibility of knowing exactly where data is stored on disk.

---

## Resources

- [Docker documentation](https://docs.docker.com)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WordPress developer reference](https://developer.wordpress.org/)
- [MariaDB knowledge base](https://mariadb.com/kb/en/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [Adminer](https://www.adminer.org/)

### AI Usage

AI was used to assist with the following tasks during this project:

- Docker configuration optimisation and best practices
- Debugging and resolving shell script and container startup issues
- Structuring documentation for clarity and subject compliance
- Reviewing Docker Compose and service configuration details   