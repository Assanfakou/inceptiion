FROM debian:12

RUN apt-get update && apt-get install -y vsftpd vim 

COPY setup/vsftp.conf /etc/vsftp.conf

COPY setup/setup.sh /setup.sh

RUN mkdir -p /var/run/vsftpd/empty

RUN chmod +x setup.sh

CMD ["./setup.sh"]
