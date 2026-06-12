#!/bin/bash

echo "Starting WordPress setup..."

# Download WordPress files if empty
if [ ! -f /var/www/html/wp-login.php ]; then
    echo "Downloading WordPress..."
    wp core download --path=/var/www/html --allow-root
    chown -R www-data:www-data /var/www/html
fi

# try to connect with the mariadb and run a command there
# if the command runs stop if not whait for it ,
echo "connect to mariadb"
until mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" > /dev/null; do
	echo "whiting for connection with mariadb"
	sleep 1
done

cd /var/www/html

# create config if not exists
echo "creating configuration"
if [ ! -f wp-config.php ]; then
	echo "Creating wp-config.php..."
	wp config create \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="$DB_HOST" \
		--allow-root
	else
		echo "wp-config.php already exists. Skipping creation."
fi

echo "installation the core "

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "WordPress is not installed. Installing core now..."
    wp core install \
        --url="$WP_URL" \
        --title="Inception" \
	--admin_user="$WP_USER_ADMIN" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
	--allow-root
else
    echo "WordPress is already installed. Skipping core installation."
fi

if ! wp plugin is-installed redis-cache --allow-root ; then
	echo " << Installine the plugins >>"
	wp plugin install redis-cache --activate --allow-root
	wp config set WP_REDIS_HOST "redis" --allow-root
	wp config set WREDIS_PORT "6379" --allow-root
	wp redis enable --allow-root
else
	echo " << Plugins already installed >> "
fi

# create second user if not exists
if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
	echo "Ceating second user..."

	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--user_pass="$WP_USER_PASSWORD" \
		--role=author \
		--allow-root
else
	echo "WordPress 2nd user already there"
fi

echo "start the PHP-FPM"
exec php-fpm8.2 -F
