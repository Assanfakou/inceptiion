<div align="center">

# Inception

*A peaceful Docker-orchestrated web stack — built for the 42 school curriculum*

**by hfakou**

---

</div>

## What is this?

Inception packages a complete web ecosystem inside isolated Docker containers, wired together with a single Compose file. Every service is built from a custom Dockerfile. The stack is designed for repeatability, clean networking, and data that survives container restarts.

---

## Services

| Service | Role |
|---|---|---|
| **NGINX** | SSL/TLS reverse proxy and sole public entry-point |
| **WordPress** | PHP-FPM application served behind NGINX |
| **MariaDB** | Relational database for WordPress data |
| **Redis** | In-memory cache that speeds up WordPress |
| **Adminer** | Browser-based database management UI |
| **FTP** | File-transfer access to the WordPress directory |
| **Portainer** | Docker management UI for containers and volumes |

---

## Getting Started

### Prerequisites

- Linux host with Docker and Docker Compose installed
- `sudo` privileges — the Makefile updates `/etc/hosts`

### 1 · Configure your environment

Create a `srcs/.env` file and fill in these values:

```env
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
WP_URL=
WP_TITLE=
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=
WP_USER=
WP_USER_EMAIL=
WP_USER_PASSWORD=
FTP_USER=
FTP_PASSWORD=
```

> ⚠️ Never commit this file to version control.

### 2 · Launch the stack

```bash
make all        # build images + start the stack
make up         # start without rebuilding
make down       # stop the stack
make clean      # stop + remove containers, volumes, and local data
make status         # check container status
make logs       # follow live logs
```

---

## Architecture

All containers share a single Docker network called `inception`. They reach each other by service name — no hard-coded IPs needed. NGINX is the only container exposed to the outside world (port 443).

```
Internet
   │
  443
   │
┌──▼──────┐     ┌───────────┐     ┌─────────┐
│  NGINX  │────▶│ WordPress │────▶│ MariaDB │
└─────────┘     └───────────┘     └─────────┘
                      │                 ▲
                      ▼                 │
                  ┌───────┐       ┌─────────┐
                  │ Redis │       │ Adminer │
                  └───────┘       └─────────┘
```

### Data persistence

Persistent data is stored on Docker volumes bound to the host filesystem:

| Volume | Host path |
|---|---|
| WordPress files | `~/data/wordpress` |
| MariaDB data | `~/data/mariadb` |

These survive `make down` / `make up` cycles — your content stays safe.

---

## Design Choices

| Topic | Choice | Alternative |
|---|---|---|
| Virtualisation | Docker — lightweight, fast, shares host kernel | VMs — stronger isolation but heavier |
| Credentials | `.env` file for dev convenience | Docker Secrets — better for production |
| Networking | User-defined bridge `inception` for DNS by name | Host network — less isolation |
| Storage | Bind-backed Docker volumes under `~/data` | Pure bind mounts — less portable |

---

## Resources

- [Docker documentation](https://docs.docker.com)
- [Docker Compose](https://docs.docker.com/compose/)
- [WordPress developer reference](https://developer.wordpress.org/)
- [MariaDB knowledge base](https://mariadb.com/kb/en/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [Adminer](https://www.adminer.org/)

---

## AI Assistance

AI tools supported this project in the following areas:

- Docker configuration optimisation and best practices
- Debugging shell scripts and container startup issues
- Structuring documentation for clarity and subject compliance
- Reviewing Compose and service configuration details

---

<div align="center">

*Created as part of the 42 school curriculum*

</div>
