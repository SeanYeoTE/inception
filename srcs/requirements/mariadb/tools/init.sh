#!/bin/bash
set -e

echo "Starting MariaDB initialization..."

# Fix permissions
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# If MariaDB not yet initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    echo "MariaDB data directory initialized."
fi

echo "Ensuring database and user exist..."
# Start temporary server to run SQL
mariadbd --user=mysql --datadir=/var/lib/mysql --socket=/tmp/mysql.sock --pid-file=/tmp/mysqld.pid &
PID=$!

# Wait for server to be ready
until [ -S /tmp/mysql.sock ]; do
    echo "Waiting for MariaDB socket..."
    sleep 1
done

# Check if database setup is needed
if mysql -u root --socket=/tmp/mysql.sock -e "SELECT 1;" 2>/dev/null; then
    echo "Database accessible without password, performing initial setup..."
    # Fresh install - can connect without password
    mysql -u root --socket=/tmp/mysql.sock << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
elif mysql -u root -p"${MYSQL_ROOT_PASSWORD}" --socket=/tmp/mysql.sock -e "SELECT 1;" 2>/dev/null; then
    echo "Database already configured with password, skipping setup..."
    # Database exists and is accessible with password - skip setup
else
    echo "Cannot connect to database - setup may be incomplete"
fi

# Stop temporary server
kill $PID
wait $PID

echo "Database and user setup completed."

echo "Starting MariaDB server..."
exec mariadbd --user=mysql --datadir=/var/lib/mysql --console
