#!/usr/bin/env sh

set -e

echo "Setting up wordpress..."
/usr/local/bin/wp-config.sh

echo "✅ Lancement de PHP-FPM..."

mkdir -p /run/php

PHP_FPM_BIN=$(ls /usr/sbin/php-fpm* 2>/dev/null | head -n 1)

if [ -z "$PHP_FPM_BIN" ]; then
  echo "❌ Wordpress: php-fpm introuvable :(" >&2
  exit 1
fi

FPM_CONF=$(find /etc/php/ -type f -path "*/fpm/pool.d/www.conf" | head -n 1)

if [ -z "$FPM_CONF" ]; then
  echo "❌ Wordpress: www.conf introuvable"
  exit 1
fi

sed -i "s|^listen = .*|listen = 0.0.0.0:9000|" "$FPM_CONF"
ls /etc/php/*/fpm/pool.d/www.conf


exec "$PHP_FPM_BIN" -F

