# User Documentation

## Overview

This Inception project is a Docker-based web infrastructure that provides a secure WordPress deployment with NGINX reverse proxy, MariaDB database, and persistent data volumes. The system is designed to be deployed in a virtual machine environment.

## Services Provided

The infrastructure consists of the following services:

### 1. NGINX (Reverse Proxy)
- **Purpose**: Acts as the primary entry point and reverse proxy
- **Port**: 443 (HTTPS only)
- **Security**: TLS 1.2/1.3 encryption
- **Role**: Routes traffic to WordPress and handles SSL termination

### 2. WordPress + PHP-FPM
- **Purpose**: Content Management System and PHP processing
- **Features**: 
  - PHP-FPM for fast CGI processing
  - WordPress CMS functionality
  - Two user accounts (administrator + regular user)
- **Configuration**: Connected to MariaDB for data storage

### 3. MariaDB Database
- **Purpose**: Relational database for WordPress
- **Features**:
  - WordPress database with dedicated tables
  - Two users: administrator and regular user
  - Persistent database storage
- **Access**: Internal Docker network only

### 4. Data Volumes
- **Database Volume**: Persistent MariaDB data storage
- **Website Volume**: Persistent WordPress files and media
- **Location**: `/home/login/data` on host machine

## Quick Start Guide

### Prerequisites
- Virtual Machine environment
- Docker and Docker Compose installed
- Domain name configured to point to local IP

### Starting the Project

1. **Navigate to project directory**:
   ```bash
   cd /path/to/inception
   ```

2. **Start all services**:
   ```bash
   make up
   ```
   This command will:
   - Build all Docker images from scratch
   - Create required volumes and networks
   - Start all containers in the correct order

3. **Verify services are running**:
   ```bash
   make status
   ```

### Stopping the Project

1. **Stop all services**:
   ```bash
   make down
   ```

2. **Complete cleanup** (optional):
   ```bash
   make clean
   ```
   This removes containers, networks, and built images

## Accessing the Services

### WordPress Website
- **URL**: `https://your-domain.42.fr`
- **Description**: Main WordPress website
- **Access**: Web browser

### WordPress Administration Panel
- **URL**: `https://your-domain.42.fr/wp-admin`
- **Description**: WordPress admin dashboard
- **Login**: Use administrator credentials (see credentials section)

## Managing Credentials

### Credential Storage
All sensitive information is stored in the `secrets/` directory:

- `secrets/MYSQL_ROOT_PASSWORD.txt` - Database root password
- `secrets/MYSQL_USER.txt` - Database user name
- `secrets/MYSQL_PASSWORD.txt` - Database user password
- `secrets/WP_ADMIN_USER.txt` - WordPress admin username
- `secrets/WP_ADMIN_PASSWORD.txt` - WordPress admin password
- `secrets/WP_ADMIN_EMAIL.txt` - WordPress admin email

### Accessing Credentials
```bash
# View database credentials
cat secrets/MYSQL_USER.txt
cat secrets/MYSQL_PASSWORD.txt

# View WordPress admin credentials
cat secrets/WP_ADMIN_USER.txt
cat secrets/WP_ADMIN_PASSWORD.txt
```

### Security Best Practices
- Never commit secrets to version control
- Credentials are automatically ignored by git
- Use environment variables for sensitive data
- Rotate passwords regularly

## Monitoring Service Health

### Check Container Status
```bash
# List all containers and their status
docker-compose ps

# View container logs
docker-compose logs nginx
docker-compose logs wordpress
docker-compose logs mariadb
```

### Verify Service Functionality

1. **NGINX Health Check**:
   ```bash
   # Check if NGINX is responding
   curl -k https://your-domain.42.fr
   ```

2. **Database Connectivity**:
   ```bash
   # Access MariaDB container
   docker-compose exec mariadb mysql -u root -p
   ```

3. **WordPress Access**:
   - Open browser to `https://your-domain.42.fr`
   - Verify website loads correctly
   - Test admin login at `https://your-domain.42.fr/wp-admin`

### Volume Management

#### Viewing Volumes
```bash
# List all Docker volumes
docker volume ls

# Inspect specific volume
docker volume inspect inception_db-data
docker volume inspect inception_wordpress-data
```

---

*This user documentation covers the essential operations for end users and administrators of the Inception project. For developer-specific information, please refer to the DEV_DOC.md file.*
