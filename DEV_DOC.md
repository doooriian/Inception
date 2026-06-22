# Developer Documentation

<br />
<p align="center">
  <a href="https://42.fr/">
    <img src="https://github.com/doooriian/42-Badges/blob/main/42_Logo.png" alt="42 Logo" width="180" height="180">
  </a>

  <h1 align="center">Inception - Developer Documentation</h1>

  <p align="center">
    Technical guide for building, running, debugging and maintaining the Inception infrastructure
  </p>
</p>

---

## ✨ Overview

This document explains how to set up, build, run and maintain the **Inception** project from a developer point of view.

The project is a Docker-based infrastructure composed of three services:

```text id="f9yzoz"
nginx      -> HTTPS web server
wordpress  -> WordPress + PHP-FPM
mariadb    -> database server
```

Each service has its own Dockerfile and runs inside its own dedicated container.

Docker Compose is used to define the infrastructure.

The Makefile is used as the main command interface.

---

## 📁 Project Structure

Expected repository structure:

```text id="gib9na"
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs
    ├── docker-compose.yml
    ├── .env.example
    └── requirements
        ├── nginx
        │   ├── Dockerfile
        │   └── conf
        ├── wordpress
        │   ├── Dockerfile
        │   ├── conf
        │   └── tools
        └── mariadb
            ├── Dockerfile
            ├── conf
            └── tools
```

The real `.env` file must be created locally and must not be committed to Git.

---

## 🧰 Prerequisites

The project is designed to run in a Linux environment with Docker.

For the 42 evaluation, it should be deployed and tested inside a virtual machine, according to the subject requirements.

Required tools:

```text id="qv9fuh"
Docker
Docker Compose
Make
```

Check Docker:

```bash id="n8f2r5"
docker --version
```

Check Docker Compose:

```bash id="2yu5lo"
docker compose version
```

Check Make:

```bash id="k5v3un"
make --version
```

---

## ⚙️ Environment Setup

Create the environment file from the example:

```bash id="yx75f4"
cp srcs/.env.example srcs/.env
```

Edit it:

```bash id="3j9ax3"
nano srcs/.env
```

Example structure:

```env id="jz1f9l"
DOMAIN_NAME=login.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=change_me
MYSQL_ROOT_PASSWORD=change_me

WP_ADMIN_USER=main_user
WP_ADMIN_PASSWORD=change_me
WP_ADMIN_EMAIL=main_user@example.com

WP_USER=regular_user
WP_USER_PASSWORD=change_me
WP_USER_EMAIL=regular_user@example.com
```

The administrator username must not contain:

```text id="rjs53l"
admin
Admin
administrator
Administrator
```

The `.env` file is used to provide runtime configuration to the containers.

It must not be committed because it contains credentials.

Only `.env.example` should be present in the repository.

---

## 🔐 Environment Variables and Secrets

This project uses a `.env` file because it is required by the subject.

Environment variables are injected into containers at runtime and are used by the setup scripts.

Examples:

```text id="3t36tk"
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD
WP_ADMIN_USER
WP_ADMIN_PASSWORD
```

Docker secrets would be a safer way to handle sensitive data because secrets are mounted inside containers as files instead of being exposed directly as environment variables.

Example secret path inside a container:

```text id="k91hjt"
/run/secrets/mysql_password
```

However, this project keeps the `.env` workflow as the main configuration method, while making sure the real `.env` file is ignored by Git.

---

## 🌐 Domain Setup

The project domain must point to the local machine or the virtual machine.

Edit `/etc/hosts`:

```bash id="sy0kpm"
sudo nano /etc/hosts
```

Add:

```text id="fwsubf"
127.0.0.1 login.42.fr
```

Depending on the virtual machine network setup, `127.0.0.1` may need to be replaced with the correct local IP address.

The value must match the `DOMAIN_NAME` variable in `srcs/.env`.

---

## 🏗️ Build and Launch

From the root of the repository:

```bash id="6bqd6q"
make
```

or:

```bash id="w875b5"
make up
```

This will:

```text id="pn1jo8"
1. Create the required host data directories.
2. Build the Docker images.
3. Create the Docker network.
4. Create or reuse the Docker volumes.
5. Start all containers in detached mode.
```

The project is managed through Docker Compose using the file:

```text id="nx3j0w"
srcs/docker-compose.yml
```

---

## 🧾 Makefile Commands

### `make`

```bash id="xgwt8m"
make
```

Builds and starts the full infrastructure.

It is the default entrypoint of the project.

---

### `make up`

```bash id="y2s6fy"
make up
```

Starts the infrastructure.

It builds images if needed and runs containers in detached mode.

Equivalent Compose behavior:

```bash id="x5z1vv"
docker compose up --build -d
```

---

### `make build`

```bash id="z8z4ys"
make build
```

Builds the Docker images only.

It does not start the containers.

---

### `make ps`

```bash id="cdruoa"
make ps
```

Displays the status of the project containers.

Expected containers:

```text id="u7pqk2"
nginx
wordpress
mariadb
```

---

### `make logs`

```bash id="wxh6mz"
make logs
```

Displays logs from the containers.

If logs are followed in real time, use:

```text id="j4xubg"
Ctrl + C
```

to stop watching them.

---

### `make down`

```bash id="hx100c"
make down
```

Stops and removes:

```text id="buhffq"
containers
Docker network
```

Keeps:

```text id="lm0vpn"
images
volumes
persistent data
```

Use this when you want to stop the infrastructure without deleting the website or database data.

---

### `make fclean`

```bash id="ev4z1d"
make fclean
```

Fully removes the project.

It removes:

```text id="qdgwc9"
containers
Docker network
Docker volumes
Docker images
persistent data in /home/login/data
```

Use it only when a full reset is needed.

---

### `make re`

```bash id="7ugwsw"
make re
```

Runs a full cleanup and then starts the project again.

Equivalent behavior:

```text id="qavld9"
make fclean + make
```

---

## 🐳 Docker Compose

The Compose file defines:

```text id="b6t3wg"
services
networks
volumes
ports
build contexts
restart policies
environment files
```

Expected services:

```text id="bbn9za"
nginx
wordpress
mariadb
```

The project must not use:

```text id="j0brfm"
network: host
network_mode: host
links:
--link
```

---

## 📦 Containers

Each service runs inside its own container.

Expected containers:

```text id="4q6wkq"
nginx
wordpress
mariadb
```

Check running containers:

```bash id="jguy8y"
docker ps
```

Check project containers:

```bash id="wz8j9c"
make ps
```

Enter a container:

```bash id="x1dhxf"
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

If `bash` is not available:

```bash id="sndkcg"
docker exec -it wordpress sh
```

Run a command without entering the container:

```bash id="fn6760"
docker exec wordpress ls /var/www/html
docker exec mariadb ls /var/lib/mysql
```

---

## 🖼️ Images

List local Docker images:

```bash id="unon3q"
docker images
```

Docker images are built locally from the project Dockerfiles.

They are stored locally by Docker and are not part of the Git repository.

---

## 🌉 Docker Network

The project uses a private Docker bridge network.

Containers communicate using service names:

```text id="iobp8r"
nginx -> wordpress:9000
wordpress -> mariadb:3306
```

List Docker networks:

```bash id="w73ry6"
docker network ls
```

Inspect the project network:

```bash id="mcbt88"
docker network inspect inception_inception
```

The network should contain:

```text id="soog4u"
nginx
wordpress
mariadb
```

Docker provides internal DNS resolution.

For example, inside the `wordpress` container, the hostname `mariadb` resolves to the internal IP address of the MariaDB container.

Test DNS resolution:

```bash id="647gj5"
docker exec nginx getent hosts wordpress
docker exec wordpress getent hosts mariadb
```

---

## 💾 Volumes and Persistent Data

The project uses persistent storage for:

```text id="q9smwl"
WordPress website files
MariaDB database files
```

Expected volumes:

```text id="7rj0cq"
wordpress_data
mariadb_data
```

Inside containers:

```text id="hcftlg"
wordpress_data -> /var/www/html
mariadb_data   -> /var/lib/mysql
```

On the host machine:

```text id="zgrsim"
/home/login/data/wordpress
/home/login/data/mariadb
```

Check Docker volumes:

```bash id="770g68"
docker volume ls
```

Inspect volumes:

```bash id="c90nu3"
docker volume inspect inception_wordpress_data
docker volume inspect inception_mariadb_data
```

Check host data:

```bash id="hzbu1k"
ls -la /home/login/data/wordpress
ls -la /home/login/data/mariadb
```

Check container data:

```bash id="9nufxi"
docker exec wordpress ls /var/www/html
docker exec nginx ls /var/www/html
docker exec mariadb ls /var/lib/mysql
```

---

## 🔁 Persistence

Containers are disposable.

Important data must not live only inside a container.

This project stores WordPress files and MariaDB data in persistent volumes.

To test persistence:

```text id="eqe8p9"
1. Create or edit a WordPress page.
2. Run make down.
3. Run make.
4. Visit the website again.
```

The page should still exist.

This proves that the data is stored outside the containers.

Do not use `make fclean` to test persistence.

`make fclean` deletes the persistent data on purpose.

---

## 🌐 NGINX

NGINX is the only public entrypoint.

It exposes only port `443`.

Check HTTPS:

```bash id="7qrczz"
curl -k -I https://login.42.fr
```

The `-k` option allows `curl` to accept the self-signed TLS certificate.

Check that HTTP is not exposed:

```bash id="paxsl9"
curl -I http://login.42.fr
```

Check the NGINX configuration:

```bash id="nsk031"
docker exec nginx nginx -T
```

Check TLS protocols:

```bash id="xqd0u9"
docker exec nginx nginx -T | grep ssl_protocols
```

Expected:

```nginx id="mppkyz"
ssl_protocols TLSv1.2 TLSv1.3;
```

Check FastCGI forwarding:

```bash id="n942j5"
docker exec nginx nginx -T | grep fastcgi_pass
```

Expected:

```nginx id="5a3mrf"
fastcgi_pass wordpress:9000;
```

NGINX forwards PHP requests to the WordPress container through PHP-FPM.

---

## 🔧 WordPress and PHP-FPM

The WordPress container contains WordPress and PHP-FPM only.

It must not contain NGINX.

Check PHP-FPM processes:

```bash id="30pcn0"
docker exec wordpress ps aux | grep php
```

Expected:

```text id="lk3qxf"
php-fpm: master process
php-fpm: pool www
```

Check PHP-FPM listen address:

```bash id="9o2lku"
docker exec wordpress grep -R "listen =" /etc/php/8.2/fpm/pool.d/
```

Expected:

```text id="w9eapo"
listen = 0.0.0.0:9000
```

`0.0.0.0` allows PHP-FPM to listen on all container interfaces, making it reachable from NGINX through the Docker network.

List WordPress users:

```bash id="p4wnkz"
docker exec wordpress wp user list --allow-root
```

Check WordPress URL options:

```bash id="3uil44"
docker exec wordpress wp option get siteurl --allow-root
docker exec wordpress wp option get home --allow-root
```

Expected:

```text id="d8h5eo"
https://login.42.fr
```

---

## 🗄️ MariaDB

MariaDB stores the WordPress database.

It must not contain NGINX.

It is not exposed to the host machine.

WordPress connects to it through the Docker network using:

```text id="kw9ycw"
mariadb:3306
```

Test root without password:

```bash id="td7kx7"
docker exec -it mariadb mariadb -u root
```

Expected result:

```text id="kt9hsl"
Access denied
```

Connect as root with password:

```bash id="lqs0sj"
docker exec -it mariadb mariadb -u root -p
```

Useful SQL commands:

```sql id="lwrnkr"
SHOW DATABASES;
exit;
```

Connect from WordPress to MariaDB:

```bash id="rjve5s"
docker exec -it wordpress bash
```

Then:

```bash id="2na1d5"
mariadb -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

Useful SQL commands:

```sql id="qv1j90"
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
DESCRIBE wp_users;
SELECT ID, user_login FROM wp_users;
SELECT ID, post_title, post_type, post_status FROM wp_posts LIMIT 10;
exit;
```

Exit the WordPress container:

```bash id="owewux"
exit
```

---

## 🧹 Debug and Cleanup Commands

Show logs:

```bash id="gssqdl"
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Follow logs:

```bash id="lol432"
docker logs -f nginx
```

List all containers:

```bash id="exmser"
docker ps -a
```

List all images:

```bash id="d9rus7"
docker images
```

List all volumes:

```bash id="xgmrjo"
docker volume ls
```

List all networks:

```bash id="bfvu6b"
docker network ls
```

Global Docker cleanup, use with caution:

```bash id="llk7r6"
docker system prune -a
```

This may remove Docker resources from other projects.

---

## ⚠️ Common Issues

### Website does not load

Check containers:

```bash id="33lyxa"
make ps
```

Check NGINX logs:

```bash id="v1tx6q"
docker logs nginx
```

Check `/etc/hosts`.

Check HTTPS:

```bash id="4saqf3"
curl -k -I https://login.42.fr
```

---

### Browser shows a certificate warning

This is expected.

The project uses a self-signed TLS certificate.

---

### WordPress cannot connect to MariaDB

Check MariaDB logs:

```bash id="vyfr0a"
docker logs mariadb
```

Check WordPress environment variables:

```bash id="1v9nrj"
docker exec wordpress env | grep MYSQL
```

Test the internal connection:

```bash id="xpm271"
docker exec -it wordpress bash
mariadb -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

---

### CSS is not loaded correctly

Check that NGINX includes MIME types:

```bash id="u7qla1"
docker exec nginx nginx -T | grep mime.types
```

Expected:

```nginx id="pxwy6y"
include /etc/nginx/mime.types;
```

Test CSS content type:

```bash id="v1hgum"
curl -k -I https://login.42.fr/wp-includes/css/admin-bar.min.css
```

Expected:

```text id="s2xrd9"
Content-Type: text/css
```

---

### Data disappeared

If `make fclean` was used, this is expected.

`make fclean` deletes persistent data.

To test persistence, use:

```bash id="p5h7aw"
make down
make
```

not `make fclean`.

---

## 📬 More Information

For user and administrator instructions, see:

* **[USER_DOC.md](./USER_DOC.md)** — User and administrator documentation.

For the main project overview, see:

* **[README.md](./README.md)** — General documentation.
