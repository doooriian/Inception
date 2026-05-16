#!/bin/bash

# Exit immediately if any command fails
# Prevents the script from continuing after an error and hiding problems
set -e

# Path where WordPress files are located inside the container
WP_PATH="/var/www/html"

# MariaDB hostname — uses the environment variable if set, otherwise defaults to 'mariadb'
# 'mariadb' is the service name in docker-compose.yml, resolved by Docker internal DNS
MYSQL_HOST="${MYSQL_HOST:-mariadb}"

# Function to check that a required environment variable is set
# ${!1} is bash indirection — reads the value of the variable whose name is passed as argument
# -z tests if the string is empty
# Usage: check_env "VARIABLE_NAME"
check_env()
{
	if [ -z "${!1}" ]; then
		echo "Error: environment variable $1 is not set"
		exit 1
	fi
}

# Verify all required environment variables are defined before doing anything
# These must all be set in docker-compose.yml — the script exits immediately if any is missing
check_env "DOMAIN_NAME"			# full domain name of the site (e.g. login.42.fr)
check_env "MYSQL_DATABASE"		# name of the WordPress database in MariaDB
check_env "MYSQL_USER"			# MariaDB user WordPress will connect as
check_env "MYSQL_PASSWORD"		# password for the MariaDB user
check_env "WP_ADMIN_USER"		# username for the WordPress administrator account
check_env "WP_ADMIN_PASSWORD"	# password for the WordPress administrator account
check_env "WP_ADMIN_EMAIL"		# email address for the WordPress administrator account
check_env "WP_USER"				# username for the second WordPress user (required by Inception)
check_env "WP_USER_PASSWORD"	# password for the second WordPress user
check_env "WP_USER_EMAIL"		# email address for the second WordPress user

# Move into the WordPress directory so WP-CLI commands run from the right location
cd "$WP_PATH"

# Step 1: wait for MariaDB to respond to network connections
# mysqladmin ping sends a lightweight test signal to the MariaDB server
# MariaDB starts slower than NGINX or PHP-FPM — this loop retries every 2 seconds
# --silent suppresses output, only the exit code matters
echo "Waiting for MariaDB to be reachable..."
until mysqladmin ping -h"$MYSQL_HOST" --silent; do
	sleep 2
done

# Step 2: wait for MariaDB credentials and database to be fully ready
# MariaDB can respond to ping before finishing user/database creation
# This second check runs an actual SQL query to confirm everything is accessible
# SELECT 1 is the simplest possible query — just tests that the connection works
# >/dev/null 2>&1 discards all output — we only care whether the command succeeds
echo "Waiting for MariaDB credentials to be ready..."
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" >/dev/null 2>&1; do
	sleep 2
done

# Step 3: download WordPress core files if not already present
# wp-settings.php is a reliable indicator that WordPress files are fully present
# it is part of WordPress core and never absent from a complete installation
# --allow-root is required because we run as root inside the container
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
	echo "WordPress files not found, downloading WordPress..."
	wp core download --allow-root
fi

# Step 4: create wp-config.php if it does not exist
# wp-config.php tells WordPress how to connect to MariaDB
# wp config create generates it cleanly from the provided parameters
# This is skipped on container restart if the file already exists
if [ ! -f "$WP_PATH/wp-config.php" ]; then
	echo "Creating wp-config.php..."
	wp config create \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="$MYSQL_HOST" \
		--allow-root
fi

# Step 5: install WordPress if not already installed
# wp core is-installed checks whether WordPress tables exist in MariaDB
# wp core install creates those tables and sets up the admin account
# --skip-email prevents WordPress from trying to send a confirmation email
# (no mail server is configured in Inception)
if ! wp core is-installed --allow-root; then
	echo "Installing WordPress..."
	wp core install \
		--url="https://$DOMAIN_NAME" \
		--title="Inception" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email \
		--allow-root
fi

# Step 6: create a second WordPress user if it does not already exist
# Inception requires at least two users — one admin and one regular user
# wp user get checks if the user exists — >/dev/null 2>&1 suppresses output
# role=author gives standard writing permissions without admin access
if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
	echo "Creating additional WordPress user..."
	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--user_pass="$WP_USER_PASSWORD" \
		--role=author \
		--allow-root
fi

# Give PHP-FPM (running as www-data) ownership of all WordPress files
# -R applies recursively to all files and subdirectories
# Required so PHP-FPM can read and write files, especially wp-content/uploads/
chown -R www-data:www-data "$WP_PATH"

echo "Starting PHP-FPM..."

# Launch PHP-FPM in the foreground as PID 1
# -F prevents PHP-FPM from daemonizing (same role as 'daemon off' in NGINX)
# exec replaces the shell process with PHP-FPM so Docker signals reach it directly
exec php-fpm8.2 -F
