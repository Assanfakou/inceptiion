FROM debian:12

RUN apt-get update && apt-get install -y mariadb-server

RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql

RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
COPY setup/setup.sh setup.sh

RUN chmod +x setup.sh

CMD ["./setup.sh"]
