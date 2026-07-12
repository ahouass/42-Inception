#!/bin/bash
set -e

WP_PATH="/var/www/html"

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

echo "Waiting for MariaDB..."
until mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${DB_PASS}" "${MYSQL_DATABASE}" -e "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done
echo "Connected to MariaDB successfully!"

cd "$WP_PATH"

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."

    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost="${MYSQL_HOST}" \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WORDPRESS_USER}" \
        "${WORDPRESS_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASS}" \
        --allow-root 2>/dev/null || echo "User already exists"

    chown -R www-data:www-data "$WP_PATH"

    echo "WordPress installation complete!"
else
    echo "WordPress already installed."
fi

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F