# FTP Service (vsftpd)

## Overview

FTP (**File Transfer Protocol**) is a network protocol used to transfer files between a client and a server.

In this Inception bonus service, FTP allows us to:

- Upload files from the host machine to the WordPress volume.
- Download files from the WordPress volume to the host machine.
- Manage website files remotely.
- Share the same persistent WordPress data volume used by Nginx and WordPress.

The FTP server used in this project is **vsftpd** (**Very Secure FTP Daemon**).

---

# Why do we need FTP?

Without FTP:

```text
Host
 |
 +--> Cannot easily access files inside containers
```

With FTP:

```text
Host
 |
 +--> FTP Client
          |
          v
       FTP Server
          |
          v
    WordPress Volume
```

FTP provides a simple way to interact with the WordPress files stored inside Docker volumes.

---

# Architecture

```text
                +----------------+
                |     Host       |
                | FTP Client     |
                +-------+--------+
                        |
                        | FTP (Port 21)
                        |
                        v
                +----------------+
                | FTP Container  |
                |    vsftpd      |
                +-------+--------+
                        |
                        |
                        v
                +----------------+
                | wordpress_data |
                | Docker Volume  |
                +-------+--------+
                        |
            +-----------+-----------+
            |                       |
            v                       v
    +---------------+      +---------------+
    | WordPress     |      | Nginx         |
    | Container     |      | Container     |
    +---------------+      +---------------+
```

---

# How FTP Works

FTP uses two connections:

## 1. Control Connection

Used for:

- Authentication
- Commands
- Navigation

Default Port:

```text
21
```

Example:

```text
USER ftpuser
PASS password
LIST
PUT file.txt
GET file.txt
```

---

## 2. Data Connection

Used for:

- Uploading files
- Downloading files
- Directory listings

In Passive Mode (PASV):

```text
10000-10100
```

These ports must be exposed by Docker.

---

# vsftpd Configuration

Important settings:

```conf
listen=YES

anonymous_enable=NO

local_enable=YES

write_enable=YES

chroot_local_user=YES

allow_writeable_chroot=YES

pasv_enable=YES

pasv_min_port=10000
pasv_max_port=10100

local_root=/var/www/html
```

### Explanation

#### anonymous_enable=NO

Disables anonymous access.

Only authenticated users can connect.

---

#### local_enable=YES

Allows local Linux users to log in.

---

#### write_enable=YES

Allows uploads and modifications.

---

#### chroot_local_user=YES

Locks users inside their home directory.

This prevents access to the rest of the filesystem.

---

#### allow_writeable_chroot=YES

Allows writing inside a chrooted directory.

---

#### local_root=/var/www/html

Sets the FTP root directory.

Users immediately see WordPress files after login.

---

# Docker Integration

The FTP container mounts the same volume used by WordPress:

```yaml
ftp:
  volumes:
    - wordpress_data:/var/www/html
```

Because of this:

```text
FTP Upload
      |
      v
wordpress_data volume
      |
      +--> WordPress sees file
      |
      +--> Nginx serves file
```

All containers share the same data.

---

# Starting the Service

Build and start:

```bash
docker compose up --build
```

Check container status:

```bash
docker ps
```

Check logs:

```bash
docker logs ftp
```

---

# Testing FTP

## Connect using FTP client

```bash
ftp localhost
```

or

```bash
ftp <server-ip>
```

---

## Login

```text
Name: ftpuser
Password: ftppassword
```

---

# Useful FTP Commands

## Show current directory

```ftp
pwd
```

---

## List files

```ftp
ls
```

---

## Change directory

```ftp
cd wp-content
```

---

## Upload a file

```ftp
put file.txt
```

Example:

```ftp
put test.txt
```

---

## Download a file

```ftp
get test.txt
```

---

## Upload multiple files

```ftp
mput *.txt
```

---

## Download multiple files

```ftp
mget *.txt
```

---

## Delete file

```ftp
delete test.txt
```

---

## Create directory

```ftp
mkdir uploads
```

---

## Remove directory

```ftp
rmdir uploads
```

---

## Exit FTP

```ftp
bye
```

or

```ftp
quit
```

---

# Verification Tests

## Verify WordPress files are visible

After login:

```ftp
ls
```

Expected output:

```text
wp-admin
wp-content
wp-includes
index.php
wp-config.php
```

---

## Verify upload

Create a local file:

```bash
echo "hello" > test.txt
```

Upload:

```ftp
put test.txt
```

Verify inside WordPress container:

```bash
docker exec -it wordpress ls /var/www/html
```

Expected:

```text
test.txt
```

---

## Verify download

Inside FTP container:

```bash
touch /var/www/html/download_test.txt
```

From FTP:

```ftp
get download_test.txt
```

Verify:

```bash
ls
```

Expected:

```text
download_test.txt
```
---

# Key Takeaways

- FTP allows file transfers between host and server.
- vsftpd is the FTP server used in this project.
- Port 21 is used for commands and authentication.
- Passive ports are used for data transfers.
- FTP shares the same WordPress Docker volume.
- Uploaded files become immediately available to WordPress and Nginx.
- `put` uploads files.
- `get` downloads files.
- `ls` lists files.
- `pwd` shows the current directory.
- `bye` exits the FTP session.
