# Base image: Debian Bookworm — same as NGINX for consistency
FROM debian:bookworm

# Install required packages:
# - php-fpm			: PHP processor that runs WordPress PHP files on port 9000
# - php-mysql		: PHP extension that allows WordPress to talk to MariaDB
# - default-mysql-client : provides mysqladmin, used in setup.sh to check if MariaDB is ready
# - wget			: used to download WordPress and WP-CLI
# Chain all in one RUN to avoid creating extra image layers
# rm -rf /var/lib/apt/lists/* cleans the package cache to keep the image small
RUN apt-get update && apt-get install -y \
	php-fpm \
	php-mysql \
	default-mysql-client \
	wget \
	&& rm -rf /var/lib/apt/lists/*

# Create the directory PHP-FPM needs to store its .pid file at startup
# Not strictly required on Debian Bookworm (created automatically by the package)
# but added as a defensive precaution
RUN mkdir -p /run/php

# Set the working directory for all following commands
# Equivalent to 'cd /var/www/html' — wget and tar will run from here
WORKDIR /var/www/html

# Download WordPress, extract it directly into /var/www/html, then clean up
# --strip-components=1 removes the top-level 'wordpress/' folder during extraction
# so files land directly in /var/www/html instead of /var/www/html/wordpress/
RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzf latest.tar.gz --strip-components=1 && \
	rm latest.tar.gz

# Download WP-CLI — a command line tool to install and configure WordPress
# without needing a browser or filling a web form manually
# chmod +x makes it executable
# mv puts it in /usr/local/bin so it can be called simply as 'wp' from anywhere
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Replace the default PHP-FPM pool config with ours
# Key change: PHP-FPM will listen on port 9000 (TCP) instead of a Unix socket
# This is required so NGINX can reach PHP-FPM from a separate container
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy the startup script into the container and make it executable
# This script configures WordPress and then launches PHP-FPM
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Document that PHP-FPM listens on port 9000
# Informational only — docker-compose handles the actual network access
EXPOSE 9000

# Run the startup script when the container starts
# It will: wait for MariaDB, configure wp-config.php, install WordPress, launch PHP-FPM
CMD ["/setup.sh"]
