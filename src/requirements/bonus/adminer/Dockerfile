FROM debian:12

RUN apt-get update && apt-get install -y \
	wget \
	php-fpm \
	php 	\
	php-mysqli

RUN wget -O /var/www/html/index.php https://sourceforge.net/projects/adminer.mirror/

WORKDIR	/var/www/html

CMD ["php-fpm"]
