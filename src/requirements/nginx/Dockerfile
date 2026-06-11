FROM debian:12

RUN apt-get update && apt-get install -y nginx vim openssl

RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/OU=student/CN=hfakou.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
