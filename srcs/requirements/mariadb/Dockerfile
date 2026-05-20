# Base image: Debian Bookworm (same base as NGINX and WordPress)
FROM debian:bookworm

# Install MariaDB server.
# Clean apt cache to keep the image smaller.
# Remove any pre-created database files so the real initialization happens
# at container startup inside the mounted volume.
RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql/*

# Copy our MariaDB server configuration.
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the startup script and make it executable.
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Document that MariaDB listens on port 3306.
# This does not expose the port to the host machine.
EXPOSE 3306

# Run the startup script when the container starts.
CMD ["/setup.sh"]
