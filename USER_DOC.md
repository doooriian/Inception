# User Documentation

<br />
<p align="center">
  <a href="https://42.fr/">
    <img src="https://github.com/doooriian/42-Badges/blob/main/42_Logo.png" alt="42 Logo" width="180" height="180">
  </a>

  <h1 align="center">Inception - User Documentation</h1>

  <p align="center">
    User and administrator guide for the Inception Docker infrastructure
  </p>
</p>

---

## ✨ Overview

This document explains how to use and manage the **Inception** infrastructure as an end user or administrator.

The project provides a WordPress website running inside a Docker-based stack.

The infrastructure is composed of three services:

```text
nginx      -> HTTPS entrypoint
wordpress  -> WordPress website and administration panel
mariadb    -> database server
```

The website is available at:

```text
https://login.42.fr
```

Only HTTPS on port `443` is exposed to the host machine.

---

## 📦 Services Provided

### NGINX

NGINX is the only public entrypoint of the infrastructure.

It receives HTTPS requests on port `443` and serves the WordPress website.

It also forwards PHP requests to the WordPress container through PHP-FPM.

---

### WordPress

WordPress provides the website and the administration panel.

It runs with PHP-FPM and communicates with MariaDB to store and retrieve website data.

The WordPress administration panel is available at:

```text
https://login.42.fr/wp-admin
```

or:

```text
https://login.42.fr/wp-login.php
```

---

### MariaDB

MariaDB is the database service.

It stores WordPress data, such as:

```text
users
posts
pages
comments
settings
```

MariaDB is not exposed to the host machine.

It is only reachable from inside the Docker network.

---

## 🚀 Starting the Project

From the root of the repository, run:

```bash
make
```

or:

```bash
make up
```

This will:

```text
1. Create the required data directories.
2. Build the Docker images.
3. Create the Docker network and volumes.
4. Start all containers in detached mode.
```

Detached mode means the containers keep running in the background.

---

## 🛑 Stopping the Project

To stop the project, run:

```bash
make down
```

This stops and removes:

```text
containers
Docker network
```

It keeps:

```text
Docker images
Docker volumes
persistent data
```

This means the WordPress website and database data are preserved.

---

## 🧹 Full Cleanup

To fully remove the project, run:

```bash
make fclean
```

This removes:

```text
containers
Docker network
Docker volumes
Docker images
persistent data stored in /home/login/data
```

Use this command only when a complete reset is needed.

After `make fclean`, WordPress and MariaDB will be initialized again on the next launch.

---

## 🔁 Rebuild From Scratch

To fully clean and rebuild the project:

```bash
make re
```

This is equivalent to:

```text
make fclean + make
```

---

## 🌐 Accessing the Website

Open the following URL in a browser:

```text
https://login.42.fr
```

Because the TLS certificate is self-signed, the browser may display a security warning.

This is expected for a local project.

You can continue to the website manually from the browser warning page.

---

## 🔐 Accessing the WordPress Admin Panel

The WordPress administration panel is available at:

```text
https://login.42.fr/wp-admin
```

or:

```text
https://login.42.fr/wp-login.php
```

Use the WordPress administrator credentials defined in the local `.env` file.

The administrator username must not contain:

```text
admin
Admin
administrator
Administrator
```

---

## 🗝️ Credentials

Credentials are stored in the local environment file:

```text
srcs/.env
```

This file contains values such as:

```text
DOMAIN_NAME
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD
WP_ADMIN_USER
WP_ADMIN_PASSWORD
WP_ADMIN_EMAIL
WP_USER
WP_USER_PASSWORD
WP_USER_EMAIL
```

A template is provided here:

```text
srcs/.env.example
```

The real `.env` file must not be committed to Git because it contains sensitive values.

---

## ⚙️ Domain Configuration

The domain must point to the local machine or virtual machine.

Edit `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add:

```text
127.0.0.1 login.42.fr
```

Depending on the virtual machine network setup, `127.0.0.1` may need to be replaced with the correct local IP address.

---

## ✅ Checking That Services Are Running

Use:

```bash
make ps
```

Expected containers:

```text
nginx
wordpress
mariadb
```

They should all be marked as running or `Up`.

You can also use:

```bash
docker ps
```

---

## 📜 Checking Logs

To display logs for all services:

```bash
make logs
```

If logs are followed in real time, use:

```text
Ctrl + C
```

to stop watching them.

To display logs for a specific container:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

## 🔒 Checking HTTPS

To check that HTTPS works:

```bash
curl -k -I https://login.42.fr
```

The `-k` option allows `curl` to accept the self-signed certificate.

Expected result:

```text
HTTP/1.1 200 OK
```

or another valid HTTPS response from NGINX.

---

## 🚫 Checking That HTTP Is Not Exposed

To check that HTTP is not available:

```bash
curl -I http://login.42.fr
```

The request should fail or be refused.

Only HTTPS on port `443` should be exposed.

---

## 👤 Checking WordPress Users

To list WordPress users:

```bash
docker exec wordpress wp user list --allow-root
```

There should be at least two users:

```text
one administrator
one regular user
```

The administrator username must not contain `admin` or `administrator`.

---

## 🗄️ Checking MariaDB

MariaDB is not directly exposed to the host machine.

To access it, enter the WordPress container first:

```bash
docker exec -it wordpress bash
```

Then connect to MariaDB using the internal Docker network:

```bash
mariadb -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

Useful SQL commands:

```sql
SHOW TABLES;
SELECT ID, user_login FROM wp_users;
SELECT ID, post_title, post_type, post_status FROM wp_posts LIMIT 10;
exit;
```

Then exit the WordPress container:

```bash
exit
```

---

## 💾 Persistent Data

The project uses persistent storage so that data survives container removal and recreation.

WordPress files are stored in:

```text
/home/login/data/wordpress
```

MariaDB data is stored in:

```text
/home/login/data/mariadb
```

Inside the containers, these paths are mounted as:

```text
wordpress:/var/www/html
nginx:/var/www/html
mariadb:/var/lib/mysql
```

This means that deleting and recreating containers does not delete the website or database content.

---

## 🧪 Persistence Test

To test persistence:

```text
1. Log in to WordPress.
2. Create or edit a page.
3. Run make down.
4. Run make.
5. Visit the website again.
```

The page should still exist.

This proves that the data is stored outside the containers.

---

## 🧭 Common Commands

```bash
make
```

Build and start the project.

```bash
make up
```

Start the project.

```bash
make down
```

Stop and remove containers and network, while keeping persistent data.

```bash
make ps
```

Show container status.

```bash
make logs
```

Show container logs.

```bash
make fclean
```

Remove the whole project, including persistent data.

```bash
make re
```

Clean and rebuild everything.

---

## 🛠️ Troubleshooting

### Website does not load

Check that containers are running:

```bash
make ps
```

Check NGINX logs:

```bash
docker logs nginx
```

Check that the domain is correctly configured in `/etc/hosts`.

---

### Browser shows a certificate warning

This is expected.

The project uses a self-signed TLS certificate.

Continue manually from the browser warning page.

---

### WordPress cannot connect to the database

Check that MariaDB is running:

```bash
docker logs mariadb
```

Check that WordPress has the correct environment variables:

```bash
docker exec wordpress env | grep MYSQL
```

Check the internal connection:

```bash
docker exec -it wordpress bash
mariadb -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

---

### Data disappeared after cleanup

If `make fclean` was used, this is expected.

`make fclean` removes persistent data.

To test persistence, use:

```bash
make down
make
```

not `make fclean`.

---

## 📬 More Information

For technical details, see:

* **[DEV_DOC.md](./DEV_DOC.md)** — Developer documentation.

For the main project overview, see:

* **[README.md](./README.md)** — General documentation.
