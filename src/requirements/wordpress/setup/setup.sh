#!/bin/bash

# try to connect with the mariadb and run a command there
# if the command runs stop if not whait for it ,
until mysql -h mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e"SELECTE 1;" > /dev/null; do
	echo "whiting for connection with mariadb"
	sleep 1
done


# create config if not exists
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
echo "start the PHP-FPM"

exec php-fpm8.2 -F
