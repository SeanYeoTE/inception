NAME = inception

.PHONY: all down up build fclean re

up: 
	docker-compose -f srcs/docker-compose.yml --env-file srcs/.env up -d mariadb

down:
	docker-compose -f srcs/docker-compose.yml --env-file srcs/.env down mariadb

build:
	docker-compose -f srcs/docker-compose.yml --env-file srcs/.env build mariadb

fclean: down
	docker system prune -af --volumes

re: fclean build up