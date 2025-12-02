FROM debian:bookworm-slim

# Install PHP-FPM 8.2 and required extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-intl \
    php8.2-opcache \
    curl \
    wget \
    ca-certificates \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Ensure www-data user exists and has correct UID/GID
RUN usermod -u 82 www-data 2>/dev/null || true && \
    groupmod -g 82 www-data 2>/dev/null || true

# Create necessary directories
RUN mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html /run/php

# Download and install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' \
    /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's|;clear_env = no|clear_env = no|g' \
    /etc/php/8.2/fpm/pool.d/www.conf

# Copy entrypoint script
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init.sh"]