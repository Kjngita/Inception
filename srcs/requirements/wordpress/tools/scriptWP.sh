#!/bin/sh

set -e

# ----- Read Docker secrets -----
DB_PASSWORD=$(cat /run/secrets/mysql_pw 2>/dev/null || echo "")
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_pw 2>/dev/null || echo "")
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_pw 2>/dev/null || echo "")

# Create a shortcut for WP-CLI
WP="php -d memory_limit=512M /usr/local/bin/wp"

# Move to the WordPress installation directory
cd /var/www/html

echo "Waiting for MariaDB..."

# Wait until MariaDB is accepting connections
until mysql \
	-h mariadb \
	-P 3306 \
	-u"${MYSQL_USER}" \
	-p"$DB_PASSWORD" \
	--skip-ssl \
	-e "SELECT 1;" >/dev/null 2>&1
do
	echo "MariaDB is unavailable - retrying in 3 seconds..."
	sleep 3
done

echo "MariaDB is ready."

# Download WordPress
if [ ! -f index.php ]; then
	echo "Downloading WordPress..."
	$WP core download --allow-root
fi

# Create wp-config.php
echo "Creating/updating wp-config.php..."
$WP config create \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="mariadb:3306" \
    --force \
    --allow-root

# Wait until database is ready
until wp db check --allow-root >/dev/null 2>&1
do
	sleep 2
done

# Install WordPress
if ! wp core is-installed --allow-root >/dev/null 2>&1
then
	echo "Installing WordPress..."
	$WP core install \
		--url="https://${DOMAIN_NAME}" \
		--title="${WORDPRESS_TITLE}" \
		--admin_user="${WORDPRESS_ADMIN}" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="${WORDPRESS_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root
fi

# Create second user
if ! wp user get "${WORDPRESS_USER}" --allow-root >/dev/null 2>&1
then
	echo "Creating WordPress user..."
	wp user create \
		"${WORDPRESS_USER}" \
		"${WORDPRESS_USER_EMAIL}" \
		--user_pass="$WP_USER_PASSWORD" \
		--allow-root
fi

# Permissions
chown -R www-data:www-data /var/www/html

echo "WordPress is ready."

# Start PHP-FPM
exec php-fpm84 -F