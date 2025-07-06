#!/usr/bin/env sh

set -e

echo "⌛ Wordpress: waiting for Mariadb to be ready..."
/usr/local/bin//wait-for-it.sh mariadb:3306 -t 30 -- echo "✅ MariaDB is up"

/usr/local/bin/wp-config.sh

echo "⌛ Looking for PHP-FPM..."
mkdir -p /run/php

PHP_FPM_BIN=$(ls /usr/sbin/php-fpm* | head -n 1)

if [ -z "$PHP_FPM_BIN" ]; then
  echo "❌ Wordpress: cant find php-fpm :(" >&2
  exit 1
fi

FPM_CONF=$(find /etc/php/ -type f -path "*/fpm/pool.d/www.conf" | head -n 1)

if [ -z "$FPM_CONF" ]; then
  echo "❌ Wordpress: cant find www.conf"
  exit 1
fi

# to listen to everyone instead just localhost (mariadb is not localhost)
sed -i "s|^listen = .*|listen = 0.0.0.0:9000|" "$FPM_CONF"

echo "🚀 Starting wordpress"
exec "$PHP_FPM_BIN" -F

