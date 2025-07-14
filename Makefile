NAME = inception

.PHONY: all down up build fclean re

up: 
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up

down:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down

build:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env build

fclean: down
	docker system prune -af --volumes

re: fclean build up