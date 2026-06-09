FROM debian:12

RUN apt-get update && apt-get install -y mariadb-server

COPY setup/setup.sh setup.sh

RUN chmod +x setup.sh

CMD ["./setup.sh"]
