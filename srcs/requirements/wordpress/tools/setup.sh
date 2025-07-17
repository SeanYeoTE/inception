#!/bin/bash

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
    echo "MariaDB is not ready yet, waiting..."
    sleep 2
done

echo "MariaDB is ready!"
echo "Database connection successful with user: ${MYSQL_USER}"

# Navigate to WordPress directory
cd /var/www/wordpress
echo "Current directory: $(pwd)"
echo "WordPress files present: $(ls -la | head -5)"

# Download and configure wp-cli
echo "Downloading WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
if [ ! -f wp-cli.phar ]; then
    echo "Failed to download wp-cli, trying alternative URL..."
    curl -O https://github.com/wp-cli/wp-cli/releases/download/v2.8.1/wp-cli-2.8.1.phar
    mv wp-cli-2.8.1.phar wp-cli.phar
fi
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
echo "WP-CLI installed successfully: $(wp --version --allow-root)"

# Create wp-config.php only if it doesn't exist
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    echo "Database details: DB=${MYSQL_DATABASE}, User=${MYSQL_USER}, Host=mariadb"
    
    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --allow-root
        
    if [ $? -eq 0 ]; then
        echo "wp-config.php created successfully!"
    else
        echo "Failed to create wp-config.php!"
        exit 1
    fi
else
    echo "wp-config.php already exists, skipping creation."
fi

echo "Testing database connection with WP-CLI..."
wp db check --allow-root

# Install WordPress only if it's not already installed
# Check if WordPress tables exist in the database instead of using wp core is-installed
echo "Checking if WordPress is already installed..."
if ! mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} -e "SHOW TABLES LIKE 'wp_options';" | grep -q wp_options; then
    echo "Installing WordPress..."
    echo "Running: wp core install with URL=${DOMAIN_NAME}, admin_user=${WP_ADMIN_USER}"
    
    # Add timeout and better error handling
    timeout 60 wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception WordPress" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root \
        --user=$(WP_USER) \
        --user_password=$(WP_USER_PASSWORD) \
        --user_email=$(WP_USER_EMAIL)
    
    if [ $? -eq 0 ]; then
        echo "WordPress installation completed successfully!"
    else
        echo "WordPress installation failed or timed out!"
        echo "Attempting to check WordPress status..."
        wp core is-installed --allow-root || echo "WordPress is not properly installed"
    fi
else
    echo "WordPress is already installed, skipping installation."
fi

echo "WordPress setup phase completed, proceeding to set permissions..."

# Set proper permissions
chown -R www-data:www-data /var/www/wordpress

echo "Starting PHP-FPM..."

# Find the correct PHP-FPM binary
if command -v php-fpm7.4 >/dev/null 2>&1; then
    echo "Using php-fpm7.4"
    exec php-fpm7.4 -F
elif command -v php-fpm >/dev/null 2>&1; then
    echo "Using php-fpm"
    exec php-fpm -F
else
    echo "Error: No PHP-FPM binary found!"
    exit 1
fi
