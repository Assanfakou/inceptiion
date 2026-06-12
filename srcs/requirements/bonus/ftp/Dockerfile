FROM debian:12

RUN apt-get update && apt-get install -y vsftpd vim 

RUN useradd -m ftpuser

RUN echo "ftpuser:ftpuser" | chpasswd

COPY setup/vsftp.conf /etc/vsftp.conf
RUN mkdir -p /var/run/vsftpd/empty
RUN mkdir -p /home/ftpuser/wordpress

CMD ["vsftpd", "/etc/vsftp.conf"]
