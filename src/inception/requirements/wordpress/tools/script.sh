#!/bin/bash
set -e

echo "Waiting for MariaDB to be ready..."
until mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e "SELECT 1" >/dev/null 2>&1; do
    echo "MariaDB is unavailable - sleeping"
    sleep 3
done

echo "MariaDB is up - proceeding with WordPress installation"

# Download WordPress if not exists
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --path=/var/www/html --allow-root
    
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --path=/var/www/html \
        --allow-root \
        --skip-check

    echo "Installing WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ROOT_USER}" \
        --admin_password="${WP_ROOT_PASSWORD}" \
        --admin_email="${WP_ROOT_EMAIL}" \
        --path=/var/www/html \
        --allow-root

    echo "Creating additional user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_PASSWORD}" \
        --path=/var/www/html \
        --allow-root

    echo "WordPress installation complete!"
else
    echo "WordPress already installed, skipping installation..."
fi

# Set proper permissions
chown -R nobody:nobody /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm82 -F