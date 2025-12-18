FROM alpine:3.19

RUN apk update && apk add mariadb mariadb-client

# Create necessary directories
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy initialization script
COPY ./tools/init_db.sh /init_db.sh
COPY ./conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf

RUN chmod +x /init_db.sh

EXPOSE 3306

ENTRYPOINT ["/init_db.sh"]