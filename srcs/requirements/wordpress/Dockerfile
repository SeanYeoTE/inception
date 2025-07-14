FROM debian:bullseye

# Install PHP, extensions, and tools
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql curl wget unzip less mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Create web directory and download WordPress
RUN mkdir -p /var/www && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    rm latest.tar.gz && \
    mv wordpress /var/www/wordpress

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
