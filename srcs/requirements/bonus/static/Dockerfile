FROM debian:12


RUN apt-get update && apt-get install -y nginx

COPY www /var/www/html

CMD ["nginx", "-g", "daemon off;"]
