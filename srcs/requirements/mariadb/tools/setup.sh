#!/bin/bash

# Exit immediately if any command fails
# Prevents the script from continuing after an error and hiding problems
set -e

# Check that a required environment variable is set.
# $1 is the variable name, ${!1} expands to the value of that variable.
check_env()
{
	if [ -z "${!1}" ]; then
		echo "Error: environment variable $1 is not set"
		exit 1
	fi
}

# Required variables used to initialize the WordPress database.
check_env "MYSQL_DATABASE"
check_env "MYSQL_USER"
check_env "MYSQL_PASSWORD"
check_env "MYSQL_ROOT_PASSWORD"

# /run is temporary and may be empty when the container starts.
# MariaDB needs this directory to create its local Unix socket.
mkdir -p /run/mysqld

# MariaDB runs as the mysql Linux user, so it must own its runtime
# directory and its data directory.
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# /var/lib/mysql/mysql is MariaDB's internal system database.
# If it does not exist, the data directory has not been initialized yet.
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB data directory..."

	# Create the initial MariaDB system tables inside the data directory.
	mariadb-install-db \
		--user=mysql \
		--datadir=/var/lib/mysql \
		--skip-test-db

	echo "Configuring MariaDB..."

	# Start MariaDB in bootstrap mode.
	# This mode reads SQL from standard input, applies it to the data directory,
	# then exits. It does not start the normal network server.
	mariadbd --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	echo "MariaDB initialization complete."
fi

echo "Starting MariaDB..."

# Start MariaDB normally in the foreground.
# It reads its options from /etc/mysql/mariadb.conf.d/50-server.cnf.
# exec replaces this script with the MariaDB server process.
exec mariadbd
