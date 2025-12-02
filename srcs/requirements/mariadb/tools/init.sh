#!/bin/bash
set -e

echo "Starting MariaDB initialization..."

# Fix permissions
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# If MariaDB not yet initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "Running bootstrap SQL..."
    mariadbd --user=mysql --datadir=/var/lib/mysql --bootstrap << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "MariaDB initialization completed."
else
    echo "MariaDB already initialized, skipping."
fi

echo "Starting MariaDB server..."
exec mariadbd --user=mysql --datadir=/var/lib/mysql --console
