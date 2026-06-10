#!/bin/bash

#start the mariadb in the background so
# the docker couldn't stop the container

mysqld_safe --user=mysql &

# white untile the mariadb is ready

until mysqladmin ping --silent;do
	sleep 1;
done

#check the database existence before making another one

if ! mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e"USE $MYSQL_DATABASE;"; 2>/dev/null ;then
	# test with root if it hasn't password initialize everything
	mysql << EOF
	CREATE DATABASE '$MYSQL_DATABASE';
	CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
	GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
	FLUSH PRIVILEGES;

EOF
fi
# FLUSH PRIVILEGES; It reloads MariaDB's privilege tables so permission changes take effect immediately

#shutdown the temperary server that was runing whit the mysqld_safe

mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown;

#Mariadb becomes here the main container process

exec mariadb --user=mysql
