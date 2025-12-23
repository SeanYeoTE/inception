SHELL := /bin/bash

# Compose configuration
COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(COMPOSE_FILE)

# Data directory
DATA_DIR = $(HOME)/data

# Enable BuildKit
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: all build up down stop restart logs clean fclean re help

all: create-dirs
	@echo -e "$(GREEN)Building and starting services...$(NC)"
	$(COMPOSE) up --build -d
	@echo -e "$(GREEN)Services started successfully!$(NC)"

build:
	@echo -e "$(GREEN)Building images...$(NC)"
	$(COMPOSE) build --parallel
	@echo -e "$(GREEN)Build complete!$(NC)"

up:
	@echo -e "$(GREEN)Starting services...$(NC)"
	$(COMPOSE) up -d

down:
	@echo -e "$(YELLOW)Stopping services...$(NC)"
	$(COMPOSE) down

start:
	@echo -e "$(GREEN)Starting containers...$(NC)"
	$(COMPOSE) start

restart: down up

logs:
	$(COMPOSE) logs -f

clean:
	@echo -e "$(YELLOW)Cleaning containers and volumes...$(NC)"
	$(COMPOSE) down --volumes --remove-orphans
	@echo -e "$(GREEN)Clean complete!$(NC)"

fclean: clean
	@echo -e "$(RED)Deep cleaning Docker system...$(NC)"
	@docker stop $$(docker ps -qa) 2>/dev/null || true
	@docker rm $$(docker ps -qa) 2>/dev/null || true
	@docker rmi -f $$(docker images -qa) 2>/dev/null || true
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@docker network rm $$(docker network ls -q) 2>/dev/null || true
	@echo -e "$(GREEN)Full clean complete!$(NC)"

re: fclean all

create-dirs:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

help:
	@echo -e "$(GREEN)Available targets:$(NC)"
	@echo "  make all      - Build and start all services"
	@echo "  make build    - Build images only (parallel)"
	@echo "  make up       - Start services without rebuilding"
	@echo "  make down     - Stop and remove containers"
	@echo "  make start    - Start stopped containers"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - Follow container logs"
	@echo "  make clean    - Remove containers and volumes"
	@echo "  make fclean   - Deep clean (everything)"
	@echo "  make re       - Full rebuild from scratch"
