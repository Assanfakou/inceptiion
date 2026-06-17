# DEV_DOC.md — Developer Documentation

This document explains how to set up, build, run, and manage the Inception project from scratch.

---

## 1. Setting Up the Environment

### Prerequisites

Make sure the following are installed on your Linux machine before starting:

- **Docker** — container engine
- **Docker Compose** — for multi-container orchestration
- **make** — to use the provided Makefile shortcuts
- **sudo** privileges — So you can update the file `/etc/hosts`

To verify your setup:

```bash
docker --version
docker compose version
make --version
```

### Hosts File

You need to manually add the following line to your `/etc/hosts` file so that the domain resolves correctly on your local machine:
 
```text
127.0.0.1   hfakou.42.fr
```

### Configuration File — `srcs/.env`

All services rely on a single `.env` file located at `srcs/.env`. This file must be created manually — it is never committed to version control.

Create the file:

```bash
touch srcs/.env
```

Then fill in every variable:

```env
# MariaDB
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=your_db_password

# WordPress
WP_URL=hfakou.42.fr
WP_TITLE=My WordPress Site
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=admin@hfakou.42.fr
WP_USER=editor
WP_USER_EMAIL=editor@hfakou.42.fr
WP_USER_PASSWORD=your_user_password

# FTP
FTP_USER=ftpuser
FTP_PASSWORD=your_ftp_password
```

---

## 2. Building and Launching the Project

### Project Structure

```
inception/
├── Makefile
├── README.md
├── services_read
│   ├── Adminer.md
│   ├── FTP.md
│   ├── Mariadb.md
│   ├── Nginx.md
│   ├── Portainer.md
│   ├── Redis.md
│   └── Wordpress.md
├── srcs
│   ├── docker-compose.yml
│   └── requirements
│       ├── bonus
│       │   ├── adminer
│       │   │   └── Dockerfile
│       │   ├── ftp
│       │   │   ├── Dockerfile
│       │   │   └── setup
│       │   │       ├── setup.sh
│       │   │       └── vsftp.conf
│       │   ├── portainer
│       │   │   └── Dockerfile
│       │   ├── redis
│       │   │   └── Dockerfile
│       │   └── static
│       │       ├── Dockerfile
│       │       └── www
│       │           ├── images.jpeg
│       │           └── index.html
│       ├── mariadb
│       │   ├── Dockerfile
│       │   └── setup
│       │       └── setup.sh
│       ├── nginx
│       │   ├── conf
│       │   │   └── nginx.conf
│       │   └── Dockerfile
│       └── wordpress
│           ├── Dockerfile
│           └── setup
│               └── setup.sh
├── DEV_DOC.md
└── USER_DOC.md

```

Each subdirectory under `requirements/` contains a `Dockerfile` and any configuration files needed to build that service's image.

### Makefile Commands

All commands are run from the repository root.

| Command | What it does |
|---|---|
| `make all` |  Creates data directories, builds all images, starts the stack |
| `make up` | Starts containers without rebuilding images |
| `make down` | Stops and removes containers and networks |
| `make clean` | Runs `down` and also removes Docker volumes and local data directories |
| `make re` | Full clean rebuild — equivalent to `clean` then `all` |
| `make ps` | Shows the status of all running containers |
| `make logs` | Follows live logs from all services |

### First Launch

```bash
# 1. Clone the repository
git clone https://github.com/Assanfakou/Inception.git
cd inception

# 2. Create and fill in the environment file
cp srcs/.env.example srcs/.env   # if an example exists, otherwise create manually
nano srcs/.env

# 3. Build and start everything
make all
```

After a successful launch, open your browser and go to `https://hfakou.42.fr`.  
Accept the self-signed SSL certificate warning on first access.

---

## 3. Managing Containers and Volumes

### Useful Docker Commands

Check running containers:

```bash
docker ps
# or via Makefile:
make ps
```

Follow logs for all services:

```bash
make logs
# or directly:
docker compose -f srcs/docker-compose.yml logs -f
```

Follow logs for a single service:

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

Open a bash inside a running container:

```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

Restart a single service without restarting the whole stack:

```bash
docker compose -f srcs/docker-compose.yml restart nginx
```

Stop the full stack:

```bash
make down
```

Rebuild a single service without rebuilding the whole serveces:

```bash
docker compose up --build --no-deps service_name
```

Full reset — removes everything including volumes and local data:

```bash
make clean
```

### Managing Volumes

List all Docker volumes:

```bash
docker volume ls
```

Inspect a specific volume:

```bash
docker volume inspect srcs_wordpress_data
docker volume inspect srcs_mariadb_data
```

Remove a specific volume manually (only when the stack is down):

```bash
docker volume rm srcs_wordpress_data
```

---

## 4. Data Storage and Persistence

### Where Data Lives

All persistent data is stored on the host machine under:

```
/home/$USER/data/
├── wordpress/    ← WordPress core files, themes, plugins, uploads
└── mariadb/      ← MariaDB database files
```

These directories are created automatically by `make all` before the containers start.

### How Persistence Works

The project uses Docker volumes with bind mount options. This means Docker manages the volumes, but the actual data is written to the host directories above. When containers stop or are removed, the data remains untouched on disk.

```yaml
# Example from docker-compose.yml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/wordpress

  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/mariadb
```

### Verifying Persistence

To confirm data survives a container restart:

```bash
# 1. Create a post in WordPress at https://hfakou.42.fr/wp-admin/
# 2. Stop the stack
make down

# 3. Start the stack again
make up

# 4. Visit https://hfakou.42.fr — your post should still be there
```

### Accessing Data Directly on the Host

You can inspect or back up the data directories at any time:

```bash
ls /home/$USER/data/wordpress
ls /home/$USER/data/mariadb
```

---

## 5. Service Access Reference

| Service | URL / Command | Notes |
|---|---|---|
| WordPress site | `https://hfakou.42.fr` | Main public site |
| WordPress admin | `https://hfakou.42.fr/wp-admin/` | Use `WP_ADMIN_USER` credentials |
| Adminer | `https://hfakou.42.fr/adminer/` | Use `MYSQL_USER` credentials, server: `mariadb` |
| Static site | `https://hfakou.42.fr/static/` | Personal portfolio |
| Portainer | `https://hfakou.42.fr/portainer/` | Docker management UI |
| FTP | `ftp hfakou.42.fr` | Use `FTP_USER` credentials |