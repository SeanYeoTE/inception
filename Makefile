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

.PHONY: all build up down stop start restart logs clean fclean re status help

all: create-dirs
	@echo "$(GREEN)Building and starting services...$(NC)"
	$(COMPOSE) up --build -d
	@echo "$(GREEN)Services started successfully!$(NC)"

build:
	@echo "$(GREEN)Building images...$(NC)"
	$(COMPOSE) build --parallel
	@echo "$(GREEN)Build complete!$(NC)"

up:
	@echo "$(GREEN)Starting services...$(NC)"
	$(COMPOSE) up -d

down:
	@echo "$(YELLOW)Stopping services...$(NC)"
	$(COMPOSE) down

stop:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	$(COMPOSE) stop

start:
	@echo "$(GREEN)Starting containers...$(NC)"
	$(COMPOSE) start

restart: down up

logs:
	$(COMPOSE) logs -f

status:
	@echo "$(GREEN)=== Container Status ===$(NC)"
	$(COMPOSE) ps
	@echo ""
	@echo "$(GREEN)=== Volumes ===$(NC)"
	docker volume ls | grep inception || echo "No volumes found"
	@echo ""
	@echo "$(GREEN)=== Networks ===$(NC)"
	docker network ls | grep inception || echo "No networks found"

clean:
	@echo "$(YELLOW)Cleaning containers and volumes...$(NC)"
	$(COMPOSE) down --volumes --remove-orphans
	@echo "$(GREEN)Clean complete!$(NC)"

fclean: clean
	@echo "$(RED)Deep cleaning Docker system...$(NC)"
	@docker stop $$(docker ps -qa) 2>/dev/null || true
	@docker rm $$(docker ps -qa) 2>/dev/null || true
	@docker rmi -f $$(docker images -qa) 2>/dev/null || true
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@docker network rm $$(docker network ls -q) 2>/dev/null || true
	@echo "$(YELLOW)Cleaning data directories...$(NC)"
	@sudo rm -rf $(DATA_DIR)/wp/* $(DATA_DIR)/db/* 2>/dev/null || true
	@echo "$(GREEN)Full clean complete!$(NC)"

re: fclean all

create-dirs:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

help:
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  make all      - Build and start all services"
	@echo "  make build    - Build images only (parallel)"
	@echo "  make up       - Start services without rebuilding"
	@echo "  make down     - Stop and remove containers"
	@echo "  make stop     - Stop containers (keep state)"
	@echo "  make start    - Start stopped containers"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - Follow container logs"
	@echo "  make status   - Show containers, volumes, networks"
	@echo "  make clean    - Remove containers and volumes"
	@echo "  make fclean   - Deep clean (everything)"
	@echo "  make re       - Full rebuild from scratch"