FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

CMD ["mysqld"]
# This Dockerfile sets up a MariaDB server in a Debian Bullseye container.
