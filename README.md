<div align="center">

<a href="https://42.fr/"><img src="https://raw.githubusercontent.com/doooriian/42-Badges/main/badges/inceptione.png" width="125" alt="Inception 42 project badge" /></a>

# Inception

**Docker-based infrastructure**

<img src="https://img.shields.io/badge/42%20School-Project-0891B2?style=flat-square" alt="42 School project" />

</div>

---

## 🔎 Overview

**Inception** is an individual project at 42 School that introduces system administration through Docker.

The goal of the project is to build a small web infrastructure composed of multiple services, each running in its own dedicated Docker container.

This infrastructure includes:

* **NGINX** as the only public entrypoint.
* **WordPress** running with **PHP-FPM**.
* **MariaDB** as the database service.
* A private Docker network connecting the containers.
* Persistent Docker volumes for the WordPress files and database data.

The final website is available through:

```text
https://login.42.fr
```

Only port `443` is exposed to the host machine.

---

## 📚 Documentation

Additional documentation is available in the following files:

* **[USER_DOC.md](./USER_DOC.md)** — User and administrator documentation.
* **[DEV_DOC.md](./DEV_DOC.md)** — Developer documentation.

These documents explain how to use, maintain, debug and understand the infrastructure in more detail.

---

## ✨ Key Features

* **Containerized Infrastructure**
  Each service runs in its own isolated Docker container.

* **NGINX with TLS**
  NGINX is configured as the only public entrypoint and serves the website over HTTPS using TLSv1.2 or TLSv1.3.

* **WordPress with PHP-FPM**
  WordPress is installed and configured with PHP-FPM.
  The WordPress container does not contain NGINX.

* **MariaDB Database**
  MariaDB stores WordPress data such as users, posts, pages, comments and settings.
  The MariaDB container does not contain NGINX.

* **Private Docker Network**
  Containers communicate with each other through a dedicated Docker bridge network.

* **Persistent Storage**
  WordPress files and MariaDB data are stored in persistent Docker volumes.

* **Automatic Restart**
  Containers are configured to restart automatically in case of failure.

---

## 🛠️ Technologies Used

* **[Docker](https://docs.docker.com/reference/)** — Containerization platform.
* **Docker Compose** — Multi-container orchestration.
* **[NGINX](https://nginx.org/en/docs/)** — HTTPS web server and reverse proxy.
* **WordPress** — Content management system.
* **PHP-FPM** — FastCGI process manager used to execute PHP code.
* **[MariaDB](https://mariadb.com/docs)** — Relational database server.
* **OpenSSL** — TLS certificate generation.
* **Makefile** — Build and automation tool.

---

## 🏗️ Project Description

### Global Architecture

The infrastructure is composed of three services:

```text
nginx      -> HTTPS web server
wordpress  -> WordPress + PHP-FPM
mariadb    -> database server
```

<p align="center">
  <img src="https://github.com/doooriian/42-Badges/blob/main/inception_architecture.png" alt="Inception Architecture" width="800">
</p>

NGINX is the only container exposed to the host machine.

WordPress and MariaDB are only reachable inside the private Docker network.

---

### Docker Usage

Docker is used to isolate each service in a dedicated container.

Each container has a single responsibility:

```text
nginx      -> handles HTTPS requests
wordpress  -> runs WordPress and PHP-FPM
mariadb    -> stores the database
```

Docker Compose is used to define and manage the full stack from a single `docker-compose.yml` file.

The Makefile is used as the main entrypoint to build, start, stop and clean the project.

---

### Sources Included in the Project

The project is organized as follows:

```text
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

The real `.env` file is not committed to the repository because it contains credentials.

A `.env.example` file is provided as a template.

---

### Main Design Choices

The project follows the principle of one service per container.

This makes the infrastructure easier to understand, isolate and debug.

NGINX is the only exposed service because it acts as the public web entrypoint.

WordPress and MariaDB are hidden inside the Docker network and communicate only through internal service names.

Persistent data is stored outside the containers so that it survives restarts, rebuilds and container recreation.

---

## ⚖️ Technical Comparisons

### Virtual Machines vs Docker

A virtual machine virtualizes a full operating system, including its own kernel.

A Docker container shares the host kernel and only isolates the application and its environment.

Virtual machines are heavier and slower to start.

Docker containers are lighter, faster to recreate, and better suited for separating services in this project.

Inception itself must be run inside a virtual machine, but the services inside the project are managed with Docker containers.

---

### Secrets vs Environment Variables

Environment variables are simple configuration values injected into containers at runtime.

They are easy to use and are required in this project through a `.env` file.

However, environment variables are not the safest way to store sensitive data.

Docker secrets are designed to handle confidential values more securely.

For this project, the `.env` file is used for configuration, but it must never be committed to the Git repository.

---

### Docker Network vs Host Network

A Docker network creates an isolated private network between containers.

Containers can reach each other by service name, for example:

```text
nginx -> wordpress:9000
wordpress -> mariadb:3306
```

Host network mode makes a container use the host machine network directly.

This reduces isolation and is forbidden in this project.

Inception uses a Docker bridge network to keep the stack isolated while allowing internal communication between services.

---

### Docker Volumes vs Bind Mounts

A Docker volume is persistent storage managed by Docker.

A bind mount directly maps a specific host path into a container.

In this project, Docker named volumes are used for persistent storage.

They are mounted into the containers at the paths required by each service:

```text
wordpress_data -> /var/www/html
mariadb_data   -> /var/lib/mysql
```

The data is stored on the host machine under:

```text
/home/login/data/wordpress
/home/login/data/mariadb
```

This allows WordPress files and MariaDB data to persist even if containers are stopped, removed or recreated.

---

## 🚀 Instructions

### Prerequisites

The project must be run inside a virtual machine.

Required tools:

* Docker
* Docker Compose
* Make

---

### Clone the Repository

```bash
git clone git@github.com:doooriian/Inception.git
cd Inception
```

---

### Configure Environment Variables

Create the local `.env` file from the example:

```bash
cp srcs/.env.example srcs/.env
```

Then edit it:

```bash
nano srcs/.env
```

Example variables:

```env
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

The WordPress administrator username must not contain:

```text
admin
Admin
administrator
Administrator
```

---

### Configure the Domain Name

Add the domain to `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add:

```text
127.0.0.1 login.42.fr
```

Depending on the virtual machine network configuration, `127.0.0.1` may need to be replaced with the appropriate local IP address.

---

### Build and Run

From the root of the repository:

```bash
make
```

or:

```bash
make up
```

The project will build the images and start the containers in detached mode.

---

### Stop the Project

```bash
make down
```

This stops and removes the containers and the Docker network, but keeps the persistent data.

---

### Clean the Project

```bash
make fclean
```

**Warning:** this removes containers, networks, volumes, images and persistent data, and the Makefile also deletes `$(HOME)/data` with `sudo rm -rf`. Only run it if that directory is dedicated to this project.

---

### Rebuild From Scratch

```bash
make re
```

---

## 🧪 Testing

Check that all containers are running:

```bash
make ps
```

Expected containers:

```text
nginx
wordpress
mariadb
```

Check HTTPS:

```bash
curl -k -I https://login.42.fr
```

Check that HTTP is not exposed:

```bash
curl -I http://login.42.fr
```

List Docker images:

```bash
docker images
```

List Docker volumes:

```bash
docker volume ls
```

List Docker networks:

```bash
docker network ls
```

Check WordPress users:

```bash
docker exec wordpress wp user list --allow-root
```

Connect from WordPress to MariaDB:

```bash
docker exec -it wordpress bash
mariadb -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
```

Useful SQL commands:

```sql
SHOW TABLES;
SELECT ID, user_login FROM wp_users;
exit;
```

---

## 📚 Resources

* **[NGINX Documentation](https://nginx.org/en/docs/)**
  Official NGINX documentation.

* **[Docker Documentation](https://docs.docker.com/reference)**
  Official Docker documentation and reference.

* **[MySQL 8.4 Reference Manual](https://dev.mysql.com/doc/refman/8.4/en)**
  SQL and relational database reference.

* **[MariaDB Documentation](https://mariadb.com/docs)**
  Official MariaDB documentation.

---

## 🏅 Results

Here’s my score for the Inception project:

<p align="center">
  <img src="https://github.com/doooriian/42-Badges/blob/main/badges/100Grade.png" alt="Inception grade: 100" width="140">
</p>


---

## 📬 Contact

Feel free to reach out or contribute to this project on [GitHub](https://github.com/doooriian)!
