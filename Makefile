NAME = inception

up: 
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up

down:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down

certs:
	./generate_openssl_cert.sh seayeo.42.fr

build: certs
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env build

fclean: down
	docker system prune -af --volumes

all: build up
	@echo "All services are up and running."


re: fclean build up