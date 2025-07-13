FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY tools/init.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 3306

CMD ["mysqld"]
