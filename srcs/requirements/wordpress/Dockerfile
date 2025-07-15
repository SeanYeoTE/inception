FROM debian:bullseye

# Install PHP, extensions, and tools
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql curl wget unzip less mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/listen.allowed_clients = 127.0.0.1/;listen.allowed_clients = 127.0.0.1/' /etc/php/7.4/fpm/pool.d/www.conf

# Create web directory and download WordPress
RUN mkdir -p /var/www && \
    cd /var/www && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    rm latest.tar.gz && \
    mv wordpress wordpress_temp && \
    mkdir -p wordpress && \
    mv wordpress_temp/* wordpress/ && \
    rmdir wordpress_temp

WORKDIR /var/www/wordpress

# Set proper permissions
RUN chown -R www-data:www-data /var/www/wordpress

# Create PHP-FPM socket directory
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

# Copy setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Expose the PHP-FPM port
EXPOSE 9000

# Start setup script
CMD ["/usr/local/bin/setup.sh"]
