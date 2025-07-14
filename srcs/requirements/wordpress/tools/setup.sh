#!/bin/bash

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
    echo "MariaDB is not ready yet, waiting..."
    sleep 2
done

echo "MariaDB is ready!"

# Navigate to WordPress directory
cd /var/www/wordpress

# Download and configure wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
if [ ! -f wp-cli.phar ]; then
    echo "Failed to download wp-cli, trying alternative URL..."
    curl -O https://github.com/wp-cli/wp-cli/releases/download/v2.8.1/wp-cli-2.8.1.phar
    mv wp-cli-2.8.1.phar wp-cli.phar
fi
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Create wp-config.php
wp config create \
    --dbname=${MYSQL_DATABASE} \
    --dbuser=${MYSQL_USER} \
    --dbpass=${MYSQL_PASSWORD} \
    --dbhost=mariadb \
    --allow-root

# Install WordPress
wp core install \
    --url=${DOMAIN_NAME} \
    --title="Inception WordPress" \
    --admin_user=${WP_ADMIN_USER} \
    --admin_password=${WP_ADMIN_PASSWORD} \
    --admin_email=${WP_ADMIN_EMAIL} \
    --allow-root

# Set proper permissions
chown -R www-data:www-data /var/www/wordpress

# Start PHP-FPM
exec php-fpm7.4 -F
