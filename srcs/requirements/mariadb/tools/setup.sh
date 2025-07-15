#!/bin/bash

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background for setup
mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 &
MYSQL_PID=$!

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
until mysqladmin ping >/dev/null 2>&1; do
    sleep 1
done

echo "MariaDB is ready, setting up database..."

# Set root password and create database/user
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" 2>/dev/null || \
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');"

mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

echo "Database setup complete!"

# Stop the background MariaDB process
kill $MYSQL_PID
wait $MYSQL_PID 2>/dev/null

# Start MariaDB in foreground mode
echo "Starting MariaDB in foreground mode..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
