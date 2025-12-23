# Developer Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Environment Setup](#environment-setup)
4. [Development Workflow](#development-workflow)
5. [Container Management](#container-management)
6. [Configuration Files](#configuration-files)
7. [Data Persistence](#data-persistence)

## Architecture Overview

### System Design
The Inception project implements a modern containerized web infrastructure following microservices architecture principles:

```
┌─────────────────────────────────────────────────────────────┐
│                    Client (Firefox Browser)                  │
│                    Debian 13.2.0 + XFCE                     │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTPS (TLS 1.2/1.3)
┌─────────────────────┴───────────────────────────────────────┐
│                   NGINX Container                            │
│              (Reverse Proxy & SSL Termination)               │
└─────────────────────┬───────────────────────────────────────┘
                      │ Internal Docker Network
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼────────┐         ┌────────▼────────┐
│ WordPress      │         │   MariaDB       │
│ + PHP-FPM      │         │   Container     │
│ Container      │         │                 │
│                │         │ - Database      │
│ - CMS          │         │ - Data Volume   │
│ - PHP Engine   │         │                 │
└────────────────┘         └─────────────────┘
        │                           │
        └─────────────┬─────────────┘
                      │
        ┌─────────────┴─────────────┐
        │        Data Volumes       │
        │ - WordPress Files         │
        │ - Database Storage        │
        └───────────────────────────┘
```

## Project Structure

```
inception/
├── Makefile                     # Build and deployment automation
├── README.md                    # Project overview and quick start
├── USER_DOC.md                  # End-user documentation
├── DEV_DOC.md                   # Developer documentation (this file)
├── task_progress.md             # Development progress tracking
├── .gitignore                   # Git ignore rules
├── .env                         # Environment variables (git-ignored)
├── secrets/                     # Sensitive credentials (git-ignored)
│   ├── MYSQL_DATABASE.txt
│   ├── MYSQL_PASSWORD.txt
│   ├── MYSQL_ROOT_PASSWORD.txt
│   ├── MYSQL_USER.txt
│   ├── WP_ADMIN_EMAIL.txt
│   ├── WP_ADMIN_PASSWORD.txt
│   ├── WP_ADMIN_USER.txt
│   ├── WP_USER_EMAIL.txt
│   ├── WP_USER_PASSWORD.txt
│   └── WP_USER.txt
└── srcs/                        # Source configurations
    ├── docker-compose.yml       # Service orchestration
    ├── .env                     # Service environment variables
    └── requirements/            # Service-specific configurations
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── default.conf
        │   ├── ssl/
        │   │   ├── your-domain.42.fr.crt
        │   │   └── your-domain.42.fr.key
        │   └── tools/
        │       └── init.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── my.cnf
        │   └── tools/
        │       └── init.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   └── tools/
        │       └── init.sh
```

## Environment Setup

### Prerequisites
1. **Virtual Machine**: Debian 13.2.0 with XFCE desktop environment
2. **Docker**: Version 20.10+
3. **Docker Compose**: Version 1.29+
4. **Make**: For build automation
5. **Domain Configuration**: DNS pointing to VM IP
6. **Browser**: Firefox for testing and administration

### Initial Setup Steps

1. **Update System (Debian 13.2.0)**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install curl wget git make -y
   ```

2. **Install Docker on Debian**:
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Add user to docker group
   sudo usermod -aG docker $USER
   
   # Install Docker Compose (for Docker Compose V1 compatibility)
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Note: Modern Docker installations include 'docker compose' (V2) plugin
   # Use 'docker compose' commands instead of 'docker-compose' when available
   
   # Logout and login again for group changes to take effect
   ```

3. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd inception
   ```

4. **Configure Environment Variables**:
   ```bash
   # Edit the .env file with your specific values
   nano srcs/.env
   ```

5. **Generate Self-Signed SSL Certificates**:
   ```bash
   # Generate self-signed certificates for development/testing
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout srcs/requirements/nginx/ssl/seayeo.42.fr.key \
      -out srcs/requirements/nginx/ssl/seayeo.42.fr.crt \
      -subj "/C=SG/ST=Singapore/L=Singapore/O=42 Singapore/CN=seayeo.42.fr"
   
   # Set proper permissions
   chmod 600 srcs/requirements/nginx/ssl/seayeo.42.fr.key
   chmod 644 srcs/requirements/nginx/ssl/seayeo.42.fr.crt
   ```

6. **Generate Credentials**:
   ```bash
   # Create static credentials for development/testing
   echo "mysqldb" > secrets/MYSQL_DATABASE.txt
   echo "seayeo" > secrets/MYSQL_USER.txt
   echo "root1234" > secrets/MYSQL_ROOT_PASSWORD.txt
   echo "sean1234" > secrets/MYSQL_PASSWORD.txt
   echo "seayeo" > secrets/WP_ADMIN_USER.txt
   echo "admin_secure_pass" > secrets/WP_ADMIN_PASSWORD.txt
   echo "seayeo@student.42.fr" > secrets/WP_ADMIN_EMAIL.txt
   echo "regularuser" > secrets/WP_USER.txt
   echo "user_password" > secrets/WP_USER_PASSWORD.txt
   echo "user@student.42.fr" > secrets/WP_USER_EMAIL.txt
   ```

7. **Build and Start Services**:
   ```bash
   make up
   ```

### Required Environment Variables

**srcs/.env Configuration**:
```bash
# Database Configuration
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/MYSQL_ROOT_PASSWORD
MYSQL_DATABASE_FILE=/run/secrets/MYSQL_DATABASE
MYSQL_USER_FILE=/run/secrets/MYSQL_USER
MYSQL_PASSWORD_FILE=/run/secrets/MYSQL_PASSWORD

# WordPress Configuration
DOMAIN_NAME_FILE=/run/secrets/DOMAIN_NAME
WP_ADMIN_USER_FILE=/run/secrets/WP_ADMIN_USER
WP_ADMIN_PASSWORD_FILE=/run/secrets/WP_ADMIN_PASSWORD
WP_ADMIN_EMAIL_FILE=/run/secrets/WP_ADMIN_EMAIL
WP_USER_FILE=/run/secrets/WP_USER
WP_USER_EMAIL_FILE=/run/secrets/WP_USER_EMAIL
WP_USER_PASSWORD_FILE=/run/secrets/WP_USER_PASSWORD
```

## Development Workflow

### Makefile Targets

| Command | Description |
|---------|-------------|
| `make up` | Build and start all services |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make build` | Build Docker images |
| `make clean` | Remove containers, networks, and images |
| `make logs` | View service logs |
| `make status` | Check container status |
| `make re` | Rebuild and restart services |

### Development Commands

1. **Incremental Development**:
   ```bash
   # Modify configuration files
   nano srcs/requirements/nginx/conf/default.conf
   
   # Rebuild specific service
   docker compose build nginx
   docker compose restart nginx
   ```

2. **Database Access**:
   ```bash
   # Connect to MariaDB container
   docker compose exec mariadb mysql -u root -p

   # Execute SQL commands
   docker compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"
   ```

3. **WordPress CLI**:
   ```bash
   # Access WordPress container
   docker compose exec wordpress bash
   ```

4. **Log Monitoring**:
   ```bash
   # Follow all logs
   docker compose logs -f
   
   # Follow specific service logs
   docker compose logs -f nginx
   ```

## Container Management

### Service Dependencies
```
nginx → wordpress → mariadb
```

### Container Lifecycle

1. **Startup Sequence**:
   - MariaDB starts first (database dependency)
   - WordPress starts second (depends on database)
   - NGINX starts last (reverse proxy for WordPress)

2. **Health Checks**:
   - Each container includes health check configurations
   - Automatic restart on failure
   - Dependency-aware startup

3. **Network Configuration**:
   ```yaml
   networks:
     default:
       driver: bridge
   ```

## Configuration Files

### Docker Compose Configuration

**srcs/docker-compose.yml Structure**:
```yaml
services:
  nginx:
    build: ./requirements/nginx
    container_name: inception_nginx
    restart: unless-stopped
    ports:
      - "443:443"
    volumes:
      - wordpress-data:/var/www/html
    depends_on:
      - wordpress
    networks:
      - inception

  wordpress:
    build: ./requirements/wordpress
    container_name: inception_wordpress
    restart: unless-stopped
    volumes:
      - wordpress-data:/var/www/html
    depends_on:
      - mariadb
    networks:
      - inception
    env_file:
      - .env

  mariadb:
    build: ./requirements/mariadb
    container_name: inception_mariadb
    restart: unless-stopped
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - inception
    env_file:
      - .env

volumes:
  db-data:
    driver: local
  wordpress-data:
    driver: local

networks:
  inception:
    driver: bridge
```

### Environment Variables Strategy

1. **Build-time Variables**: Defined in `.env`
2. **Runtime Secrets**: Mounted via Docker secrets
3. **Container-specific**: Service-specific environment files

### SSL Configuration

**NGINX SSL Configuration**:
```nginx
server {
    listen 443 ssl;
    server_name seayeo.42.fr;

    ssl_certificate     /etc/nginx/ssl/seayeo.42.fr.crt;
    ssl_certificate_key /etc/nginx/ssl/seayeo.42.fr.key;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include fastcgi.conf;
        fastcgi_pass wordpress:9000;
    }
}
```

## Data Persistence

### Volume Management

1. **Database Volume** (`db-data`):
   - **Path**: `/var/lib/mysql` (MariaDB)
   - **Host Mount**: `/home/login/data/db`

2. **WordPress Volume** (`wordpress-data`):
   - **Path**: `/var/www/html` (WordPress files)
   - **Host Mount**: `/home/login/data/wordpress`

### Volume Operations

```bash
# List volumes
docker volume ls

# Inspect volume details
docker volume inspect inception_db-data
docker volume inspect inception_wordpress-data
```
