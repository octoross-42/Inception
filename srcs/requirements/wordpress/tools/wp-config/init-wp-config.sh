#!/usr/bin/env sh
set -e
rm -f ./wp-config.php

wp core download --allow-root --locale=fr_FR || { echo "❌ Wordpress: fail dl wp"; exit 1; }

echo "⌛ Wordpress: wp config create..."
wp config create \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASS" \
    --dbhost=mariadb \
    --dbprefix="_" \
    --locale=fr_FR \
    --allow-root || { echo "❌ Wordpress: fail config create"; exit 1; }


echo "⌛ Wordpress: wp config WP_CACHE/WP_DEBUG/FORCE_SSL_ADMIN..."
wp config set WP_CACHE true --raw --allow-root || { echo "❌ Wordpress: fail config set WP_CACHE"; exit 1; }
wp config set WP_DEBUG true --raw --allow-root || { echo "❌ Wordpress: fail config set WP_DEBUG"; exit 1; }
wp config set FORCE_SSL_ADMIN true --raw --allow-root || { echo "❌ Wordpress: fail config set FORCE_SSL_ADMIN"; exit 1; }

echo "⌛ Worpress: wp core install..."
wp core install \
    --url="https://$DOMAIN_NAME" \
    --title="$WEBSITE_TITLE" \
    --admin_user="$WP_ADMIN_NAME" \
    --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_MAIL" \
    --skip-email \
    --allow-root || { echo "❌ Wordpress: fail core install"; exit 1; }

echo "⌛ Wordpress: create user..."
wp user create "$WP_USER_NAME" "$WP_USER_MAIL" \
    --user_pass="$WP_USER_PASS" \
    --role="editor" \
    --allow-root || { echo "❌ Wordpress: fail create user"; exit 1; }

echo "✅ Wordpress: database init done !"