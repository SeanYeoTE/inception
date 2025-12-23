*This project has been created as part of the 42 curriculum by seayeo.*

## Description

Inception is a system administration project that broadens knowledge of containerization using Docker. This project involves setting up a complete WordPress infrastructure using multiple Docker containers, each running specific services with proper networking, volume management, and security configurations.

The goal is to create a small-scale but production-ready infrastructure consisting of:
- **NGINX** web server with TLS/SSL encryption
- **WordPress** with PHP-FPM
- **MariaDB** database server
- Proper volume management for data persistence
- Docker networking for inter-container communication

## Architecture Overview

### Service Architecture
```
Internet (Port 443)
    ↓
[NGINX Container - Port 443]
    ↓
[WordPress + PHP-FPM Container]
    ↓
[MariaDB Container]
```

### Container Design
- **NGINX**: Acts as the reverse proxy and SSL terminator, only entry point to the infrastructure
- **WordPress**: Handles PHP processing with PHP-FPM, serves the web application
- **MariaDB**: Provides database services for WordPress data storage

### Volume Management
- **Database Volume**: Persistent storage for MariaDB data (`/home/seayeo/data/mariadb`)
- **WordPress Volume**: Persistent storage for WordPress files (`/home/seayeo/data/wordpress`)


## Instructions

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Configure environment variables:**
   Edit the `.env` file in the `srcs/` directory:
   ```bash
   cd srcs
   cp .env.example .env  # If applicable
   nano .env
   ```

3. **Set up domain configuration:**
   - Update your `/etc/hosts` file to point your domain to localhost
   - Configure DNS to point `seayeo.42.fr` to your VM's IP address

### Deployment

The project uses a Makefile for easy management:

```bash
# Build and start all services
make all

# Build images only (parallel build)
make build

# Start services without rebuilding
make up

# Stop services
make down

# Restart services
make restart

# View logs
make logs

# Clean containers and volumes
make clean

# Deep clean (removes all Docker resources)
make fclean

# Full rebuild from scratch
make re
```

### Accessing the Services

- **Website**: `https://seayeo.42.fr` (port 443 only)
- **WordPress Admin**: `https://seayeo.42.fr/wp-admin/`

### Data Persistence

Data is persisted in the following locations:
- Database: `/home/seayeo/data/mariadb/`
- WordPress files: `/home/seayeo/data/wordpress/`

## Technical Design Choices

### Virtual Machines vs Docker

Between Virtual Machines and Docker, the main difference is that virtual machines create seperate operationg systems with their own kernel, which causes significant resource overhead and much slower startup times, as they are all individual systems. Compare to Docker, all services share the host system's kernel while isolating system processes making them lighter as the os requirements are omitted and only necessary resources for the services are installed in the container.
Docker is the clear choice because they require us to setup the services in docker containers using docker compose and the efficiency and portability benefits are ahead of virtual machines for our usage.

### Secrets vs Environment Variables

Environment variables are key value pairs that can appear in logs so its not safe to store passwords and API keys. Docker secrets provide encrypted storage designed for this kind of sensitive data, ensuring that only the specifed data is accessible by the containers that need them. I have used docker secrets for all sensitive information while retaining environment variables for config purposes. 

### Docker Network vs Host Network

In a host network, containers share the host network namespace directly. this can lead to port conflicts as services have direct access to the host ports without any mapping involved. A custom docker bridge network is better used, as it creates an isolated environment where docker containers can communicate with each other using automatic dns resolution provided by docker itself while preventing external access from the wrong ports. 

### Docker Volumes vs Bind Mounts

i chose to use bind mounts here so that i could debug easier and control where the data is stored. and easily define for data persistence across restarts as long the stored data location is not deleted
Docker volumes might be a better implementation choice to improve portability across different systems but it is not necessary in the current project as we are only submitting in a single virtual machine.

## AI Usage

AI assistance was used for:
- **Documentation Generation**: Defining README.md structure/syntax to follow
- **Docker Configuration Optimization**: Identifying Docker best practices
- **Troubleshooting**: Aiding in Debugging methods pertaining to container networking and volume mounting issues

## Troubleshooting

### Common Issues

1. **Containers not starting:**
   ```bash
   make logs
   ```
   Check for configuration errors or missing secrets.

2. **Database connection errors:**
   - Verify MariaDB container is running: `docker ps`
   - Check WordPress container logs for connection details

3. **SSL Certificate issues:**
   - Ensure SSL certificates are properly mounted in NGINX container
   - Verify domain name configuration matches certificate

4. **Volume permission errors:**
   - Check that data directories exist: `/home/*user*/data/`
   - Verify proper ownership and permissions

### Health Checks

Monitor container status:
```bash
# View running containers
docker ps

# Check container logs
make logs

# View resource usage
docker stats
```

## Resources

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WordPress Docker Official Images](https://hub.docker.com/_/wordpress)
- [NGINX Configuration Guide](https://nginx.org/en/docs/)
- [MariaDB Docker Documentation](https://hub.docker.com/_/mariadb)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

*For detailed user and developer documentation, see USER_DOC.md and DEV_DOC.md respectively.*
