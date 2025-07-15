FROM debian:bullseye

# Install nginx and cleanup
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/www/wordpress /etc/nginx/ssl

# Copy NGINX config and certificates
COPY conf/default.conf /etc/nginx/sites-available/default
COPY certs/ /etc/nginx/ssl/

# Expose HTTPS port
EXPOSE 443

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]
