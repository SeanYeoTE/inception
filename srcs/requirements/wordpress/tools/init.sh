#!/bin/bash

set -e

echo "Starting WordPress setup..."

# Wait for MariaDB to be ready
echo "Waiting for database..."
max_tries=30
count=0

until mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
    count=$((count + 1))
    if [ $count -gt $max_tries ]; then
        echo "ERROR: Database connection timeout!"
        exit 1
    fi
    echo "Database not ready, waiting... ($count/$max_tries)"
    sleep 3
done

echo "Database is ready!"

# Download and configure WordPress
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Setting up WordPress..."
    
    # Download WordPress core files
    echo "Downloading WordPress core..."
    wp core download --allow-root
    
    # Create wp-config.php with database settings
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
    
    # Install WordPress
    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Project" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
    
    # Create additional non-admin user
    echo "Creating regular user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
    
    echo "WordPress installation complete!"
else
    echo "WordPress already installed, skipping setup."
fi

# Set correct permissions
echo "Setting file permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM 8.2..."
# Start PHP-FPM in foreground (proper PID 1)
exec php-fpm8.2 -F
