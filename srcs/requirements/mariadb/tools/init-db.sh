#!/bin/bash
set -e


CONFIG_FILE="/app/state/.env.json"
# Créer config actuelle en JSON
CURRENT_CONFIG=$(jq -n \
  --arg DB_ROOT_PASS "$DB_ROOT_PASS" \
  '{
    "DB_ROOT_PASS": $DB_ROOT_PASS,
  }')

if [ -f "$CONFIG_FILE" ]; then
	OLD_CONFIG=$(cat "$CONFIG_FILE")
	else
	OLD_CONFIG=""
fi


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



if [ ! -f "$CONFIG_FILE" ]; then
	echo "Mariadb: first db setup"
	mysql -u root <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
		FLUSH PRIVILEGES;
EOSQL
else
	echo "Mariadb: update db setup"
	OLD_DB_ROOT_PASS=$(echo "$OLD_CONFIG" | jq -r .DB_ROOT_PASS)
	mysql -u root -p"${OLD_DB_ROOT_PASS}" <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
		FLUSH PRIVILEGES;
EOSQL

fi

echo "$CURRENT_CONFIG" > "$CONFIG_FILE"

mysqladmin -uroot -p"${DB_ROOT_PASS}" shutdown || {
	echo "❌ MariaDB shutdown failed"
	exit 1
}

# echo "BIND ADDRESS MARIADB BIS"
# cat /etc/mysql/my.cnf | grep "bind-address =" | cat

echo "⌛ Waiting for MariaDB shutdown..."
while [ -f /var/run/mysqld/mysqld.pid ] && kill -0 "$(cat /var/run/mysqld/mysqld.pid)" 2>/dev/null; do
	sleep 0.2
done
