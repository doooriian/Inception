# Inception

> **42 School project** · Docker · Infrastructure · Linux

A small containerized web stack built from individual Docker images, with HTTPS, persistent storage, and service isolation.

## Overview

Inception is a systems administration exercise: deploy WordPress behind NGINX, connect it to MariaDB, and keep the services separated on a private Docker network.

## Features

- NGINX entry point serving HTTPS on port `443`
- WordPress application running with PHP-FPM
- MariaDB for persistent application data
- Dedicated Docker images and network isolation
- Persistent host-backed storage for the database and website

## Technical approach

```text
Browser
   |
 HTTPS :443
   |
 NGINX -------- WordPress (PHP-FPM)
                       |
                    MariaDB
```

Each service has its own Dockerfile in `srcs/requirements/`. Docker Compose orchestrates the containers, networking and volumes. The host-backed data directories are created by the root Makefile.

**Stack:** Docker · Docker Compose · NGINX · WordPress/PHP-FPM · MariaDB · Shell · Make.

## Build and usage

**Platform:** Linux virtual machine with Docker Engine, Docker Compose and Make.

```bash
git clone https://github.com/doooriian/Inception.git
cd Inception
cp srcs/.env.example srcs/.env
```

Edit `srcs/.env` with your local configuration and non-default credentials. Configure the domain in `/etc/hosts` as appropriate to the VM setup.

```bash
make        # build and start
make ps     # container status
make logs   # follow logs
make down   # stop
```

The setup exposes HTTPS on port `443`. Local certificates may require trust configuration in the browser.

**Warning:** `make fclean` is destructive: it removes Docker resources and runs `sudo rm -rf $(HOME)/data`. Check that directory before using the command.

## Verification

Check the container status with `make ps`, open the configured HTTPS domain, and verify that the three services can communicate. No automated CI test suite is included.

## Notes and limitations

- Designed for the 42 Linux VM environment, not a production hosting template
- Credentials belong in the untracked local `srcs/.env`, never in Git
- The root Makefile assumes that `$(HOME)/data` is dedicated to this project
- NGINX is the only service whose port is published to the host

## Documentation

- [User guide](USER_DOC.md) — setup, usage and day-to-day operation
- [Developer guide](DEV_DOC.md) — architecture, maintenance and troubleshooting

---

Part of the [42 curriculum](https://42.fr/). Explore the other projects on [my GitHub profile](https://github.com/doooriian).
