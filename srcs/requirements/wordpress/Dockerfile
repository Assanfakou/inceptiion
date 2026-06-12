FROM debian:12

RUN apt-get update && apt-get install -y curl \
	php-fpm \
	php 	\
	mariadb-client \
	php-mysql

# Install WP-CLI Command line to manage users or create them with password ..
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

#RUN mkdir -p /var/www/html

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

WORKDIR /var/www/html

COPY setup/setup.sh /wordpress.sh
RUN chmod +x /wordpress.sh 

CMD ["/wordpress.sh"]
