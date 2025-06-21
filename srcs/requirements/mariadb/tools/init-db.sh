#!/bin/bash
set -e

# Initialise MariaDB si la base n'existe pas TODO changer en fonction de DB_NAME DB_USER etc
echo "⏳ Mariadb: Installing database..."
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

mysqld_safe --skip-networking &
echo "⌛ Mariadb: waiting for Mariadb to be ready..."
while [ ! -S /run/mysqld/mysqld.sock ]; do
	sleep 0.2
done
echo "✅ MariaDB is ready"

echo "⌛ Mariadb: Configuring database..."
mysql -u root -p"${DB_PASS}" <<-EOSQL
	-- commentaire ajoute mdp pour user pour acceder a la database
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASS}';
	CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
	-- commentaire '%' pour acceder a la db avec user depuis toutes les ips, wordpress pas dans le meme container
	CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
	GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
	FLUSH PRIVILEGES;
EOSQL


mysqladmin -uroot -p"${DB_PASS}" shutdown || {
	echo "❌ MariaDB shutdown failed"
	exit 1
}

# echo "BIND ADDRESS MARIADB BIS"
# cat /etc/mysql/my.cnf | grep "bind-address =" | cat

echo "⌛ Waiting for MariaDB shutdown..."
while [ -f /var/run/mysqld/mysqld.pid ] && kill -0 "$(cat /var/run/mysqld/mysqld.pid)" 2>/dev/null; do
	sleep 0.2
done
