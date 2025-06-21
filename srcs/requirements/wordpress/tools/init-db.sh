echo "🚀 First wordpress config detected..."
rm -f wp-config.php

echo "Wordpress: wp config create..."
wp config create \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASS" \
    --dbhost="$DB_HOST:$DB_PORT" \
    --dbprefix="$DB_PREFIX" \
    --locale=fr_FR \
    --allow-root || exit 1


echo "Wordpress: wp config WP_CACHE/WP_DEBUG/FORCE_SSL_ADMIN..."
wp config set WP_CACHE true --raw --allow-root || exit 1
wp config set WP_DEBUG true --raw --allow-root || exit 1
wp config set FORCE_SSL_ADMIN true --raw --allow-root || exit 1

echo "Worpress: wp core install..."
wp core install \
    --url="$DOMAIN_NAME" \
    --title="$WEBSITE_TITLE" \
    --admin_user="$WP_ADMIN_NAME" \
    --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_MAIL" \
    --skip-email \
    --allow-root || exit 1

echo "Wordpress: create user..."
wp user create "$WP_USER_NAME" "$WP_USER_MAIL" \
    --user_pass="$WP_USER_PASS" \
    --role="author" \
    --skip-email \
    --allow-root || exit 1

echo "Wordpress: database init done !"