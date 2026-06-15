 # MariaDB Service Explanation

## What is MariaDB?

MariaDB is an open-source relational database (a fork of MySQL). In this project MariaDB
stores WordPress data (posts, pages, users, settings) and is intended to be reachable
only on the internal Docker network by the WordPress container.

---

## How this image is built (Dockerfile)

Key points from `srcs/requirements/mariadb/Dockerfile`:

- **Base image:** `debian:12`.
- **Install:** `apt-get update && apt-get install -y mariadb-server` installs the server package.
- **Runtime dir:** creates `/run/mysqld` and sets ownership:

```dockerfile
RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql
```

    This ensures MariaDB can create its socket/PID files and write data.
- **Bind address change:** the Dockerfile runs:

```dockerfile
RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
```

    This replaces `127.0.0.1` with `0.0.0.0` in the server config so the server listens on all interfaces
    (required for other containers on the Docker network to connect).
- **Init script:** copies `setup/setup.sh` into the image as `setup.sh`, makes it executable and sets it
    as the container command:

```dockerfile
COPY setup/setup.sh setup.sh
RUN chmod +x setup.sh
CMD ["./setup.sh"]
```

    The container runs `./setup.sh` as PID 1 on start.

---

## `setup.sh` (init + run) explained

File: `srcs/requirements/mariadb/setup/setup.sh` — behaviour summary:

- The script starts a temporary background server to perform initialization:

```bash
mysqld_safe --user=mysql &
```

- It waits until MariaDB accepts connections:

```bash
until mysqladmin ping --silent; do
    sleep 1
done
```

- It checks whether the expected database exists by running:

```bash
if ! mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DATABASE;" 2>/dev/null ; then
    # initialization block
fi
```

    On a fresh container root typically has no password yet, so the check fails and the script
    enters the initialization block. Inside the heredoc it runs the SQL statements:

```sql
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
```

    - `CREATE DATABASE` — creates the WordPress DB
    - `CREATE USER ... IDENTIFIED BY` — creates the application user (host `%` allows connections from any host)
    - `GRANT ALL PRIVILEGES` — grants permissions on the WordPress DB
    - `ALTER USER` — sets the root password
    - `FLUSH PRIVILEGES` — applies changes

- After initialization the script shuts down the temporary server and replaces the process with the real server:

```bash
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
exec mariadbd --user=mysql
```

    Note: the final command uses `mariadbd` (the MariaDB server binary) as PID 1.

---

## Environment variables used

Make sure these environment variables are provided (for example in your `docker-compose.yml`):

- `MYSQL_ROOT_PASSWORD` — password to set for the `root`@`localhost` account during init.
- `MYSQL_DATABASE` — name of the WordPress database to create (e.g. `wordpress` or `mydb`).
- `MYSQL_USER` — application DB username to create (e.g. `wp_user`).
- `MYSQL_PASSWORD` — password for the application DB user.

If any of these are missing, initialization may fail or behave unexpectedly.

---

## Useful verification commands

Replace `<mariadb_container>` with your actual container name (commonly `mariadb` if set in `docker-compose`).

- **Connect as root (interactive):**
```bash
docker exec -it <mariadb_container> mysql -u root -p"$MYSQL_ROOT_PASSWORD"
```

- **List databases:**
```bash
docker exec -it <mariadb_container> mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"
```

- **Show tables in the WordPress DB:**
```bash
docker exec -it <mariadb_container> mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DATABASE; SHOW TABLES;"
```

- **Connect as application user:**
```bash
docker exec -it <mariadb_container> mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

- **Check listening port (container networking):**
```bash
docker exec -it <mariadb_container> ss -tlnp | grep 3306
```

- **Confirm bind-address change in config:**
```bash
docker exec -it <mariadb_container> grep -n "127.0.0.1\\|bind-address" /etc/mysql/mariadb.conf.d/50-server.cnf || true
```

---

## Notes 

- The Dockerfile uses a simple `sed` replacement to change `127.0.0.1` to `0.0.0.0`. If upstream config format changes this may need adjustment.
- The init script assumes root can connect without a password on the first run; ensure the image/container starts with an empty data directory for initialization to run.
- The application user is created with host `%` so it can connect from other containers on the Docker network.

