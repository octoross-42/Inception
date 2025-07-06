#!/bin/bash
set -e

REQUIRED_VARS=(
  DB_NAME
  DB_USER
  DB_PASS
  DB_ROOT_PASS
)

# Vérifie que chaque variable est définie
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "❌ Mariadb : pls define $var in .env file"
    exit 1
  fi
done


# faire ecouter mariabd sur toutes les adresses au lieu jsute de localhsot sinon wordpress pas content
if grep -q "^\[mysqld\]" /etc/mysql/my.cnf; then
  sed -i "/^\[mysqld\]/a bind-address = 0.0.0.0" /etc/mysql/my.cnf
else
  echo -e "[mysqld]\nbind-address = 0.0.0.0" >> /etc/mysql/my.cnf
fi
# echo "BIND ADDRESS MARIADB"
# cat /etc/mysql/my.cnf | grep "bind-address =" | cat

/usr/local/bin/init-db.sh

echo "🚀 Starting MariaDB..."
exec mysqld