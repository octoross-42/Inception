#!/usr/bin/env sh

set -e

/usr/local/bin/wp-config.sh

echo "⌛ Looking for PHP-FPM..."
mkdir -p /run/php

PHP_FPM_BIN=$(ls /usr/sbin/php-fpm* 2>/dev/null | head -n 1)

if [ -z "$PHP_FPM_BIN" ]; then
  echo "❌ Wordpress: cant find php-fpm :(" >&2
  exit 1
fi

FPM_CONF=$(find /etc/php/ -type f -path "*/fpm/pool.d/www.conf" | head -n 1)

if [ -z "$FPM_CONF" ]; then
# to listen to everyone
  echo "❌ Wordpress: cant find www.conf"
  exit 1
fi

sed -i "s|^listen = .*|listen = 0.0.0.0:9000|" "$FPM_CONF"
# echo -n "Mariadb listens on: "
# cat "$FPM_CONF" | grep "listen =" | cat
# ls /etc/php/*/fpm/pool.d/www.conf


echo "✅ PHP-FPM found"

echo "🚀 Starting wordpress"
exec "$PHP_FPM_BIN" -F

